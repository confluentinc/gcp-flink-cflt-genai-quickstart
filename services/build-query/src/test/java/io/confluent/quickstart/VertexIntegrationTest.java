package io.confluent.quickstart;

import org.apache.kafka.common.serialization.*;
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.KTable;
import org.apache.kafka.streams.kstream.Produced;
import org.apache.kafka.test.TestUtils;
import org.junit.Test;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.regex.Pattern;

import static io.confluent.quickstart.IntegrationTestUtils.mkEntry;
import static io.confluent.quickstart.IntegrationTestUtils.mkMap;
import static org.assertj.core.api.Assertions.assertThat;

public class VertexIntegrationTest {
    private static final String inputTopic = "input";
    private static final String outputTopic = "output";

    @Test
    public void shouldCountWords() {
        final List<String> inputValues = Arrays.asList(
                "Hello Kafka Streams",
                "All streams lead to Kafka"
        );
        final Map<String, String> expectedAnswers = mkMap(
                mkEntry("hello", "blah"),
                mkEntry("all", "blah")
        );

        //
        // Step 1: Configure and start the processor topology.
        //
        final Serde<String> stringSerde = Serdes.String();
        final Serde<Long> longSerde = Serdes.Long();

        final Properties streamsConfiguration = new Properties();
        streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "vertex-integration-test");
        streamsConfiguration.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "dummy config");
        streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
        // Use a temporary directory for storing state, which will be automatically removed after the test.
        streamsConfiguration.put(StreamsConfig.STATE_DIR_CONFIG, TestUtils.tempDirectory().getAbsolutePath());

        final StreamsBuilder builder = new StreamsBuilder();

        final KStream<String, String> textLines = builder.stream(inputTopic);

        final Pattern pattern = Pattern.compile("\\W+", Pattern.UNICODE_CHARACTER_CLASS);

        final KTable<String, Long> wordCounts = textLines
                .flatMapValues(value -> Arrays.asList(pattern.split(value.toLowerCase())))
                // no need to specify explicit serdes because the resulting key and value types match our default serde settings
                .groupBy((key, word) -> word)
                .count();

        wordCounts.toStream().to(outputTopic, Produced.with(stringSerde, longSerde));

        try (final TopologyTestDriver topologyTestDriver = new TopologyTestDriver(builder.build(), streamsConfiguration)) {
            //
            // Step 2: Setup input and output topics.
            //
            final TestInputTopic<Void, String> input = topologyTestDriver
                    .createInputTopic(inputTopic,
                            new IntegrationTestUtils.NothingSerde<>(),
                            new StringSerializer());
            final TestOutputTopic<String, Long> output = topologyTestDriver
                    .createOutputTopic(outputTopic, new StringDeserializer(), new LongDeserializer());

            //
            // Step 3: Produce some input data to the input topic.
            //
            input.pipeValueList(inputValues);

            //
            // Step 4: Verify the application's output data.
            //
            assertThat(output.readKeyValuesToMap()).isEqualTo(expectedAnswers);
        }
    }

}
