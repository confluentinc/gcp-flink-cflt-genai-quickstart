/*
 * Copyright Confluent Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.confluent.quickstart;

import io.confluent.common.utils.TestUtils;
import io.confluent.kafka.serializers.AbstractKafkaSchemaSerDeConfig;
import io.confluent.kafka.streams.serdes.json.KafkaJsonSchemaSerde;
import io.confluent.quickstart.model.GeneratedSql;
import io.confluent.quickstart.model.GeneratedSqlKey;
import io.confluent.quickstart.model.SqlResult;
import io.confluent.quickstart.model.SqlResultKey;
import io.confluent.quickstart.model.serdes.generatedSql.GeneratedSqlSerde;
import io.confluent.quickstart.model.serdes.generatedSqlKey.GeneratedSqlKeySerde;
import io.confluent.quickstart.model.serdes.sqlResult.SqlResultSerde;
import io.confluent.quickstart.model.serdes.sqlResultKey.SqlResultKeySerde;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.Produced;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.function.Function;
import java.util.stream.Collectors;

import static io.confluent.quickstart.HeathCheckServer.startHealthCheckServer;

public class ExecuteQuery {

    static final String inputTopic = System.getenv("TOPIC_IN");
    static final String outputTopic = System.getenv("TOPIC_OUT");
    static final String bootstrapServers = System.getenv("BOOTSTRAP_SERVER");
    static final String authKey = System.getenv("KAFKA_API_KEY");
    static final String authSecret = System.getenv("KAFKA_API_SECRET");

    static String healthCheckPort = System.getenv("HEALTH_CHECK_PORT");

    static final String schemaRegistryUrl = System.getenv("SR_URL");
    static final String schemaRegistryKey = System.getenv("SR_API_KEY");
    static final String schemaRegistrySecret = System.getenv("SR_API_SECRET");

    static BigQueryClient bigQueryClient;

    public static void main(final String[] args) throws IOException {
        if (inputTopic == null || outputTopic == null || bootstrapServers == null) {
            System.out.println("Unable to run: TOPIC_IN, TOPIC_OUT and BOOTSTRAP env vars must be set.");
            System.exit(1);
        }

        final Properties streamsConfiguration = getStreamsConfiguration(bootstrapServers, authKey, authSecret);

        Map<String, String> kafkaConfig = streamsConfiguration.stringPropertyNames().stream()
                .collect(Collectors.toMap(Function.identity(), streamsConfiguration::getProperty));

        final Map<String, String> serdeConfig = new HashMap<>() {{
            put(AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, schemaRegistryUrl);
            put(AbstractKafkaSchemaSerDeConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "USER_INFO");
            put(AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_USER_INFO_CONFIG,
                    schemaRegistryKey + ":" + schemaRegistrySecret);
        }};

        bigQueryClient = new BigQueryClient();

        final StreamsBuilder builder = new StreamsBuilder();
        executeBQStream(builder, kafkaConfig);
        final KafkaStreams streams = new KafkaStreams(builder.build(), streamsConfiguration);

        if (healthCheckPort == null) { healthCheckPort = "8080"; }
        startHealthCheckServer(Integer.parseInt(healthCheckPort));

        streams.cleanUp();
        streams.start();
        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }

    static Properties getStreamsConfiguration(final String bootstrapServers, final String key, final String secret) {
        final Properties streamsConfiguration = new Properties();
        streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "quickstart-exec-query");
        streamsConfiguration.put(StreamsConfig.CLIENT_ID_CONFIG, "quickstart-exec-query");
        streamsConfiguration.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        if (key != null && secret != null) {
            streamsConfiguration.put(StreamsConfig.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
            streamsConfiguration.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
            final String jaasConfig = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\""
                    + key + "\" password=\"" + secret + "\";";
            streamsConfiguration.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig);
        }

        streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
        streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, KafkaJsonSchemaSerde.class);
        streamsConfiguration.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 10 * 1000);
        streamsConfiguration.put(StreamsConfig.STATE_DIR_CONFIG, TestUtils.tempDirectory().getAbsolutePath());
        if (schemaRegistryUrl != null) {
            streamsConfiguration.put(AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_URL_CONFIG, schemaRegistryUrl);
            streamsConfiguration.put(AbstractKafkaSchemaSerDeConfig.BASIC_AUTH_CREDENTIALS_SOURCE, "USER_INFO");
            streamsConfiguration.put(AbstractKafkaSchemaSerDeConfig.SCHEMA_REGISTRY_USER_INFO_CONFIG,
                    schemaRegistryKey + ":" + schemaRegistrySecret);
        }
        return streamsConfiguration;
    }

    static SqlResult getQueryResults(GeneratedSql sqlRequest) throws IOException {
        SqlResult sqlResult = new SqlResult();
        sqlResult.setSessionId(sqlRequest.getSessionId());
        sqlResult.setResults(bigQueryClient.runQuery(sqlRequest.getSqlRequest()));
        return sqlResult;
    }

    static void executeBQStream(final StreamsBuilder builder,
                                Map<String, String> kafkaConfig) {

        builder.stream(inputTopic, Consumed.with(new GeneratedSqlKeySerde(kafkaConfig, true), new GeneratedSqlSerde(kafkaConfig, false)))
            // sanitize the output by removing null record values
            .filter((sessionId, req) -> sessionId != null && req != null)
            .map((sessionId, req) ->
            {
                try {
                    return new KeyValue<>(new SqlResultKey(sessionId.getSessionId()), getQueryResults(req));
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            })
            .to(outputTopic, Produced.with(new SqlResultKeySerde(kafkaConfig, true), new SqlResultSerde(kafkaConfig, false)));
    }

}
