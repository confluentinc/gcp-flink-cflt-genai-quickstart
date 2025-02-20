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
package io.confluent.examples.streams;

import io.confluent.common.utils.TestUtils;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.KTable;
import org.apache.kafka.streams.kstream.Produced;

import java.util.Arrays;
import java.util.Properties;
import java.util.regex.Pattern;

public class WordCountLambdaExample {

  static final String inputTopic = System.getenv("TOPIC_IN");
  static final String outputTopic = System.getenv("TOPIC_OUT");
  static final String bootstrapServers = System.getenv("BOOTSTRAP");
  static final String authKey = System.getenv("KEY");
  static final String authSecret = System.getenv("SECRET");

  /**
   * The Streams application as a whole can be launched like any normal Java application that has a `main()` method.
   */
  public static void main(final String[] args) {
    if (inputTopic == null || outputTopic == null || bootstrapServers == null) {
      System.out.println("Unable to run: TOPIC_IN, TOPIC_OUT and BOOTSTRAP env vars must be set.");
      System.exit(1);
    }

    // Configure the Streams application.
    final Properties streamsConfiguration = getStreamsConfiguration(bootstrapServers, authKey, authSecret);

    // Define the processing topology of the Streams application.
    final StreamsBuilder builder = new StreamsBuilder();
    createWordCountStream(builder);
    final KafkaStreams streams = new KafkaStreams(builder.build(), streamsConfiguration);

    // Always (and unconditionally) clean local state prior to starting the processing topology.
    // We opt for this unconditional call here because this will make it easier for you to play around with the example
    // when resetting the application for doing a re-run (via the Application Reset Tool,
    // https://docs.confluent.io/platform/current/streams/developer-guide/app-reset-tool.html).
    //
    // The drawback of cleaning up local state prior is that your app must rebuild its local state from scratch, which
    // will take time and will require reading all the state-relevant data from the Kafka cluster over the network.
    // Thus in a production scenario you typically do not want to clean up always as we do here but rather only when it
    // is truly needed, i.e., only under certain conditions (e.g., the presence of a command line flag for your app).
    // See `ApplicationResetExample.java` for a production-like example.
    streams.cleanUp();

    // Now run the processing topology via `start()` to begin processing its input data.
    streams.start();

    // Add shutdown hook to respond to SIGTERM and gracefully close the Streams application.
    Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
  }

  /**
   * Configure the Streams application.
   *
   * <p>Various Kafka Streams related settings are defined here such as the location of the target Kafka cluster to use.
   * Additionally, you could also define Kafka Producer and Kafka Consumer settings when needed.
   *
   * @param bootstrapServers Kafka cluster address
   * @return Properties getStreamsConfiguration
   */
  static Properties getStreamsConfiguration(final String bootstrapServers, final String key, final String secret) {
    final Properties streamsConfiguration = new Properties();
    // Give the Streams application a unique name.  The name must be unique in the Kafka cluster
    // against which the application is run.
    streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "kstreams-example");
    streamsConfiguration.put(StreamsConfig.CLIENT_ID_CONFIG, "kstreams-example-client");
    // Where to find Kafka broker(s).
    streamsConfiguration.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
    if (key != null && secret != null) {
      streamsConfiguration.put(StreamsConfig.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
      streamsConfiguration.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
      final String jaasConfig = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\""
              + key + "\" password=\"" + secret + "\";";
      streamsConfiguration.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig);
    }

    // Specify default (de)serializers for record keys and for record values.
    streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
    streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
    // Records should be flushed every 10 seconds. This is less than the default
    // in order to keep this example interactive.
    streamsConfiguration.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 10 * 1000);
    // For illustrative purposes we disable record caches.
    streamsConfiguration.put(StreamsConfig.STATESTORE_CACHE_MAX_BYTES_CONFIG, 0);
    // Use a temporary directory for storing state, which will be automatically removed after the test.
    streamsConfiguration.put(StreamsConfig.STATE_DIR_CONFIG, TestUtils.tempDirectory().getAbsolutePath());
    return streamsConfiguration;
  }

  /**
   * Define the processing topology for Word Count.
   *
   * @param builder StreamsBuilder to use
   */
  static void createWordCountStream(final StreamsBuilder builder) {
    // Construct a `KStream` from the input topic "streams-plaintext-input", where message values
    // represent lines of text (for the sake of this example, we ignore whatever may be stored
    // in the message keys).  The default key and value serdes will be used.
    final KStream<String, String> textLines = builder.stream(inputTopic);

    final Pattern pattern = Pattern.compile("\\W+", Pattern.UNICODE_CHARACTER_CLASS);

    final KTable<String, Long> wordCounts = textLines
      // Split each text line, by whitespace, into words.  The text lines are the record
      // values, i.e. we can ignore whatever data is in the record keys and thus invoke
      // `flatMapValues()` instead of the more generic `flatMap()`.
      .flatMapValues(value -> Arrays.asList(pattern.split(value.toLowerCase())))
      // Group the split data by word so that we can subsequently count the occurrences per word.
      // This step re-keys (re-partitions) the input data, with the new record key being the words.
      // Note: No need to specify explicit serdes because the resulting key and value types
      // (String and String) match the application's default serdes.
      .groupBy((keyIgnored, word) -> word)
      // Count the occurrences of each word (record key).
      .count();

    // Write the `KTable<String, Long>` to the output topic.
    wordCounts.toStream().to(outputTopic, Produced.with(Serdes.String(), Serdes.Long()));
  }

}
