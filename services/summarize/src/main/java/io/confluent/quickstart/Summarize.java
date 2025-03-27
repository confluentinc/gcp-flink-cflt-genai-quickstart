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
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.Produced;

import java.io.IOException;
import java.util.Properties;

import static io.confluent.quickstart.HeathCheckServer.startHealthCheckServer;

public class Summarize {

    static final String inputTopic = System.getenv("TOPIC_IN");
    static final String outputTopic = System.getenv("TOPIC_OUT");
    static final String bootstrapServers = System.getenv("BOOTSTRAP_SERVER");
    static final String authKey = System.getenv("KAFKA_API_KEY");
    static final String authSecret = System.getenv("KAFKA_API_SECRET");

    static final String projectId = System.getenv("GCP_PROJECT_ID");
    static final String location = System.getenv("GCP_REGION");

    static final String schemaRegistryKey = System.getenv("SR_API_KEY");
    static final String schemaRegistrySecret = System.getenv("SR_API_SECRET");

    static String healthCheckPort = System.getenv("HEALTH_CHECK_PORT");

    static final String MODEL_NAME = "gemini-2.0-flash-001";
    static final String PROMPT =
            "Summarize the following results of a SQL query in 3 sentences maximum. Use an " +
            "informal style, like a conversation. Do not describe the rows or columns. \n\n";

    static VertexClient vertexClient;

    public static void main(final String[] args) throws IOException {
        if (inputTopic == null || outputTopic == null || bootstrapServers == null) {
            System.out.println("Unable to run: TOPIC_IN, TOPIC_OUT and BOOTSTRAP env vars must be set.");
            System.exit(1);
        }

        final Properties streamsConfiguration = getStreamsConfiguration(bootstrapServers, authKey, authSecret);

        vertexClient = new VertexClient(projectId, location, MODEL_NAME);

        final StreamsBuilder builder = new StreamsBuilder();
        summarizeStream(builder);
        final KafkaStreams streams = new KafkaStreams(builder.build(), streamsConfiguration);

        if (healthCheckPort == null) { healthCheckPort = "8080"; }
        startHealthCheckServer(Integer.parseInt(healthCheckPort));

        streams.cleanUp();
        streams.start();
        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }

    static Properties getStreamsConfiguration(final String bootstrapServers, final String key, final String secret) {
        final Properties streamsConfiguration = new Properties();
        streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "quickstart-summarize-results");
        streamsConfiguration.put(StreamsConfig.CLIENT_ID_CONFIG, "quickstart-summarize-results");
        streamsConfiguration.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        if (key != null && secret != null) {
            streamsConfiguration.put(StreamsConfig.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
            streamsConfiguration.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
            final String jaasConfig = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\""
                    + key + "\" password=\"" + secret + "\";";
            streamsConfiguration.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig);
        }

        streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
        streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
        streamsConfiguration.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 10 * 1000);
        streamsConfiguration.put(StreamsConfig.STATE_DIR_CONFIG, TestUtils.tempDirectory().getAbsolutePath());
        return streamsConfiguration;
    }

    static String getSummary(String text) throws IOException {
        String completePrompt = PROMPT + text;
        return vertexClient.callModel(completePrompt);
    }

    static void summarizeStream(final StreamsBuilder builder) {
        builder.stream(inputTopic)
            .filter((sessionId, text) -> sessionId != null && text != null)
            // sanitize the output by removing null record values
            .map((sessionId, text) ->
            {
                try {
                    return new KeyValue<>(sessionId.toString(), getSummary(text.toString()));
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            })
            .to(outputTopic, Produced.with(Serdes.String(), Serdes.String()));
    }

}
