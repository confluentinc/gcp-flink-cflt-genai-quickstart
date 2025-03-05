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

import com.google.cloud.speech.v1.*;
import com.google.protobuf.ByteString;
import io.confluent.common.utils.TestUtils;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.Produced;
import org.codehaus.jackson.map.ObjectMapper;

import java.io.IOException;
import java.util.Collection;
import java.util.Properties;



public class AudioToText {
    private static final ObjectMapper mapper = new ObjectMapper();

    //static final String inputTopic = System.getenv("TOPIC_IN");
    //static final String outputTopic = System.getenv("TOPIC_OUT");
    //static final String bootstrapServers = System.getenv("BOOTSTRAP");
    static final String authKey = System.getenv("KEY");
    static final String authSecret = System.getenv("SECRET");
    static final String inputTopic = "audio_request";
    static final String outputTopic = "input_request";
    static final String bootstrapServers = "pkc-619z3.us-east1.gcp.confluent.cloud:9092";

    static final String projectId = System.getenv("PROJECT_ID");
    static final String location = System.getenv("LOCATION");

    public static void main(final String[] args) {
        if (inputTopic == null || outputTopic == null || bootstrapServers == null) {
            System.out.println("Unable to run: TOPIC_IN, TOPIC_OUT and BOOTSTRAP env vars must be set.");
            System.exit(1);
        }

        // Configure the Streams application.
        final Properties streamsConfiguration = getStreamsConfiguration(bootstrapServers, authKey, authSecret);

        //vertexClient = new VertexClient(projectId, location, MODEL_NAME);

        // Define the processing topology of the Streams application.
        final StreamsBuilder builder = new StreamsBuilder();
        audioToTextStream(builder);
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

    static Properties getStreamsConfiguration(final String bootstrapServers, final String key, final String secret) {
        final Properties streamsConfiguration = new Properties();
        streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "quickstart-audio-to-text");
        streamsConfiguration.put(StreamsConfig.CLIENT_ID_CONFIG, "quickstart-audio-to-text");
        streamsConfiguration.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        if (key != null && secret != null) {
            streamsConfiguration.put(StreamsConfig.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
            streamsConfiguration.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
            final String jaasConfig = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\""
                    + key + "\" password=\"" + secret + "\";";
            streamsConfiguration.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig);
        }

        streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
        streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.BytesSerde.class);
        // Records should be flushed every 10 seconds. This is less than the default
        // in order to keep this example interactive.
        streamsConfiguration.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 10 * 1000);

        // For illustrative purposes we disable record caches.
        streamsConfiguration.put(StreamsConfig.STATESTORE_CACHE_MAX_BYTES_CONFIG, 0);
        // Use a temporary directory for storing state, which will be automatically removed after the test.
        streamsConfiguration.put(StreamsConfig.STATE_DIR_CONFIG, TestUtils.tempDirectory().getAbsolutePath());
        return streamsConfiguration;
    }

    static String audioToText(byte[] audioBytes) {
        // Instantiate Google Cloud Speech-To-Text API client
        try (SpeechClient speechClient = SpeechClient.create()) {
            RecognitionConfig config = RecognitionConfig.newBuilder()
                    .setEncoding(RecognitionConfig.AudioEncoding.LINEAR16)
                    .setLanguageCode("en-US") // Or any other supported language
                    .build();
            RecognitionAudio audio = RecognitionAudio.newBuilder()
                    .setContent(ByteString.copyFrom(audioBytes))
                    .build();

            SpeechRecognitionResult result = speechClient.recognize(config, audio).getResultsList().get(0);
            SpeechRecognitionAlternative alternative = result.getAlternativesList().get(0);
            return alternative.getTranscript();
        } catch (Exception e) {
            e.printStackTrace();
            return "Error during transcription";
        }
    }

    public class AudioQuery {

        private String sessionId;
        private byte[] audio;

        public byte[] getAudio() {
            return audio;
        }

        public String getSessionId() {
            return sessionId;
        }


    }
    static void audioToTextStream(final StreamsBuilder builder) {

        final  AudioQuery input;
        {
            try {
                input = mapper.readValue(inputTopic, AudioQuery.class);
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
        // Create a stream from the input topic
        KStream<String, AudioQuery> sourceStream = builder.stream((Collection<String>) input);
        sourceStream
                .filter((sessionId, audioQuery) -> sessionId != null && audioQuery != null)
                .map((sessionId, audioQuery) -> {
                    // Access the byte array from AudioQuery and pass it to audioToText
                    return new KeyValue<>(sessionId, audioToText(audioQuery.getAudio()));
                })
                .to(outputTopic, Produced.with(Serdes.String(), Serdes.String())); // Ensure outputTopic is properly defined to capture the transformation
    }
}



