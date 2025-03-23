package io.confluent.quickstart;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.confluent.common.utils.TestUtils;
import io.confluent.kafka.streams.serdes.json.KafkaJsonSchemaSerde;
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
import java.util.Properties;

import static io.confluent.quickstart.HeathCheckServer.startHealthCheckServer;

public class ExecuteQueryString {

    static final String inputTopic = System.getenv("TOPIC_IN");
    static final String outputTopic = System.getenv("TOPIC_OUT");
    static final String bootstrapServers = System.getenv("BOOTSTRAP_SERVER");
    static final String authKey = System.getenv("KAFKA_API_KEY");
    static final String authSecret = System.getenv("KAFKA_API_SECRET");

    static String healthCheckPort = System.getenv("HEALTH_CHECK_PORT");

    static BigQueryClient bigQueryClient;

    // POJO classes
    public static void main(final String[] args) throws IOException {
        if (inputTopic == null || outputTopic == null || bootstrapServers == null) {
            System.out.println("Unable to run: TOPIC_IN, TOPIC_OUT and BOOTSTRAP env vars must be set.");
            System.exit(1);
        }

        final Properties streamsConfiguration = getStreamsConfiguration(bootstrapServers, authKey, authSecret);

        bigQueryClient = new BigQueryClient();

        final StreamsBuilder builder = new StreamsBuilder();
        executeBQStream(builder);
        final KafkaStreams streams = new KafkaStreams(builder.build(), streamsConfiguration);

        if (healthCheckPort == null) { healthCheckPort = "8080"; }
        startHealthCheckServer(Integer.parseInt(healthCheckPort));

        streams.cleanUp();
        streams.start();
        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }

    static Properties getStreamsConfiguration(final String bootstrapServers, final String key, final String secret) {
        final Properties streamsConfiguration = new Properties();
        streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "quickstart-exec-query-string");
        streamsConfiguration.put(StreamsConfig.CLIENT_ID_CONFIG, "quickstart-exec-query-string");
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
        return streamsConfiguration;
    }

    static String ExtractJson(String rawRequest) {
        // extract json = from the first '{' to the last '}'
        int posBegin = rawRequest.indexOf('{');
        int posEnd = rawRequest.lastIndexOf('}');
        return rawRequest.substring(posBegin, posEnd+1);
    }

    static String ExtractRequest(String jsonString) throws JsonProcessingException {
        // parse JSON
        HashMap objectMap = new HashMap<String, String>();
        ObjectMapper objectMapper = new ObjectMapper();
        objectMap = objectMapper.readValue(jsonString, HashMap.class);
        // return the "sql_request" field
        String retVal = (String) objectMap.get("sql_request");
        return retVal;
    }

    static String getQueryResults(String rawRequest) throws IOException {
        String jsonString = ExtractJson(rawRequest);
        String request = ExtractRequest(jsonString);
        return bigQueryClient.runQuery(request);
    }

    static void executeBQStream(final StreamsBuilder builder) {

        builder.stream(inputTopic, Consumed.with(Serdes.String(), Serdes.String()))
                // sanitize the output by removing null record values
                .filter((sessionId, req) -> sessionId != null && req != null)
                .map((sessionId, req) ->
                {
                    try {
                        return new KeyValue<>(sessionId.toString(), getQueryResults(req));
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                })
                .to(outputTopic, Produced.with(Serdes.String(), Serdes.String()));
    }
}
