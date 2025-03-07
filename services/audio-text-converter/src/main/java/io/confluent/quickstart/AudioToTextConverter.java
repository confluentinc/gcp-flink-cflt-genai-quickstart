package io.confluent.quickstart;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.speech.v1.RecognitionAudio;
import com.google.cloud.speech.v1.RecognitionConfig;
import com.google.cloud.speech.v1.RecognizeResponse;
import com.google.cloud.speech.v1.SpeechClient;
import com.google.cloud.speech.v1.SpeechRecognitionResult;
import com.google.cloud.texttospeech.v1.AudioConfig;
import com.google.cloud.texttospeech.v1.AudioEncoding;
import com.google.cloud.texttospeech.v1.SsmlVoiceGender;
import com.google.cloud.texttospeech.v1.SynthesisInput;
import com.google.cloud.texttospeech.v1.SynthesizeSpeechRequest;
import com.google.cloud.texttospeech.v1.SynthesizeSpeechResponse;
import com.google.cloud.texttospeech.v1.TextToSpeechClient;
import com.google.cloud.texttospeech.v1.TextToSpeechSettings;
import com.google.cloud.texttospeech.v1.VoiceSelectionParams;
import com.google.protobuf.ByteString;
import io.confluent.common.utils.TestUtils;
import io.confluent.quickstart.model.AudioQuery;
import io.confluent.quickstart.model.AudioResponse;
import io.confluent.quickstart.model.SQLRequest;
import io.confluent.quickstart.model.serdes.AudioQuerySerde;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.KeyValue;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.Produced;
import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.text.TextContentRenderer;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Properties;

@Slf4j
public class AudioToTextConverter {

//    static final String inputTopic = System.getenv("TOPIC_IN");
//    static final String outputTopic = System.getenv("TOPIC_OUT");
//    static final String bootstrapServers = System.getenv("BOOTSTRAP");

    static final String bootstrapServers = System.getenv("BOOTSTRAP_SERVER");
    static final String authKey = System.getenv("KAFKA_API_KEY");
    static final String authSecret = System.getenv("KAFKA_API_SECRET");
    static final String schemaRegistryUrl = System.getenv("SR_URL");
    static final String schemaRegistryKey = System.getenv("SR_API_KEY");
    static final String schemaRegistrySecret = System.getenv("SR_API_SECRET");
//    static final String bootstrapServers = "pkc-619z3.us-east1.gcp.confluent.cloud:9092";
//    static final String authKey = "HL5EZLFK5GQJBK6Q";
//    static final String authSecret = "enVmMVHVPUk0vGrX54535M0AU5LOq2Zd1MntPy3IE61Iv4WcV6ybHnemjOErez5T";
//    static final String schemaRegistryUrl = "https://psrc-09gzk9.us-east1.gcp.confluent.cloud";
//    static final String schemaRegistryKey = "QESOLWTTIBYDAB3R";
//    static final String schemaRegistrySecret = "ywsav71F2/K8L0k4Qw7Y+rl13y5kAJ7Vfa2opsriMkUdH3CYfZS9QRajjgHfye0u";

//    static final String schemaRegistryUrl = "";
//    static final String schemaRegistryKey = "";
//    static final String schemaRegistrySecret = "";
//    static final String authKey = System.getenv("KEY");
//    static final String authSecret = System.getenv("SECRET");

    static final String audioRequestTopic = "audio_request";
    static final String inputRequestTopic = "input_request";

    static final String summarisedResultsTopic = "summarised_results";
    static final String audioResponseTopic = "audio_response";
    static final String projectId = System.getenv("PROJECT_ID");
    static final String location = System.getenv("LOCATION");

    public static void main(String[] args) {
        
        // Build and start the Kafka Streams application
        final Properties streamsConfiguration = getStreamsConfiguration(bootstrapServers, authKey, authSecret);
        Map<String, String> kafkaConfig = (Map) streamsConfiguration;

        // Configure Kafka Streams
        StreamsBuilder builder = new StreamsBuilder();
        
        buildAudioToTextStream(builder, kafkaConfig);
//        buildTextToAudioStream(builder, kafkaConfig);

        final KafkaStreams streams = new KafkaStreams(builder.build(), streamsConfiguration);

        streams.cleanUp();
        streams.start();
        Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
    }

    private static void buildAudioToTextStream(StreamsBuilder builder, Map<String, String> kafkaConfig) {
        // Define processing for the audio-to-text conversion
        KStream<String, AudioQuery> inputRequests = builder.stream(audioRequestTopic, Consumed.with(Serdes.String(), new AudioQuerySerde(kafkaConfig, false)));
        // Call Google Speech-to-Text API and return transcribed text
        inputRequests
                .filter((sessionId, text) -> sessionId != null && text != null)
                .mapValues(AudioToTextConverter::transcribeAudio)
                .to(inputRequestTopic, Produced.with(Serdes.String(), Serdes.String()));
    }

//    private static void buildTextToAudioStream(StreamsBuilder builder, Map<String, String> kafkaConfig) {
//
//        // Define processing for the text-to-audio conversion
//        KStream<String, String> summarizedResults = builder.stream(summarisedResultsTopic, Consumed.with(Serdes.String(), new SQLResponseSerde(kafkaConfig, false)));
//
//        // Call Google Text-to-Speech API and return audio bytes
//        summarizedResults
//                .filter((sessionId, text) -> sessionId != null && text != null)
//                .mapValues(AudioToTextConverter::synthesizeSpeech)
//                .to(audioResponseTopic, Produced.with(Serdes.String(), Serdes.String()));
//    }


    // Method to transcribe audio using Google Speech-to-Text
    private static String transcribeAudio(AudioQuery audioQuery) {
        // Initialize the return text
        log.info("audioQueryString: {} : {}", audioQuery.getSessionId(), audioQuery.getAudio());

        try (SpeechClient speechClient = SpeechClient.create()) {

            // Builds the sync recognize request
            RecognitionConfig config = RecognitionConfig.newBuilder()
                    .setEncoding(RecognitionConfig.AudioEncoding.WEBM_OPUS)
//                    .setSampleRateHertz(16000)
                    .setLanguageCode("en-US") // Set the language of the audio
                    .build();

            RecognitionAudio audio = RecognitionAudio.newBuilder()
                    .setContent(ByteString.copyFrom(audioQuery.getAudio()))
                    .build();

            // Performs speech recognition on the audio file
            RecognizeResponse response = speechClient.recognize(config, audio);

            List<SpeechRecognitionResult> results = response.getResultsList();
            if (results.isEmpty()) {
                log.info("No results found for session id: {}", audioQuery.getSessionId());
            }

            log.info("Done processing audio for session id: {}\n{}", audioQuery.getSessionId(), results);

            final String query = results.getFirst().getAlternatives(0).getTranscript();
            return new SQLRequest(query, audioQuery.getSessionId()).toString();

        } catch (Exception e) {
            log.error("Failure to transcribe Audio for session id: {}", audioQuery.getSessionId(), e);
        }

        return null;
    }

    // Method to synthesize speech using Google Text-to-Speech
    private static String synthesizeSpeech(String sessionId, String sqlResponse) {
        // Google Text-to-Speech API call

        log.info("Processing text for session id: {}", sessionId);

        final TextToSpeechSettings settings;
        final Parser parser = Parser.builder().build();
        final TextContentRenderer renderer = TextContentRenderer.builder().build();
        AudioResponse audioResponse = new AudioResponse();

        try {
            settings = TextToSpeechSettings.newBuilder().setEndpoint("texttospeech.googleapis.com:443").build();
        } catch (IOException e) {
            log.error("Error creating TextToSpeechSettings.", e);
            throw new RuntimeException(e);
        }

        try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create(settings)) {
            // Make sure the summary doesn't include any markdown formatting
            Node document = parser.parse(sqlResponse);
            final String renderedText = renderer.render(document);

            SynthesizeSpeechRequest request =
                    SynthesizeSpeechRequest.newBuilder()
                            .setInput(SynthesisInput.
                                    newBuilder()
                                    .setText(renderedText)
                                    .build())
                            .setVoice(VoiceSelectionParams.newBuilder()
                                    .setLanguageCode("en-US")
                                    .setSsmlGender(SsmlVoiceGender.FEMALE)
                                    .build())
                            .setAudioConfig(AudioConfig.newBuilder()
                                    .setAudioEncoding(AudioEncoding.MP3)
                                    .addEffectsProfileId("telephony-class-application")
                                    .build())
                            .build();

            // Call Text-to-Speech API
            SynthesizeSpeechResponse response = textToSpeechClient.synthesizeSpeech(request);
            final byte[] audio = response.getAudioContent().toByteArray();

            log.info("Done processing text for session id: {}", sessionId);
            return null;
//            return getAudioResponse(sqlResponse, audio).toString();
        } catch (Exception e) {
            log.error("Error processing text for session id: {}", sessionId, e);
            throw new RuntimeException(e);
        }
    }

//    private static AudioResponse getAudioResponse( sqlResponse, byte[] audio) {
//        final AudioResponse audioResponse = new AudioResponse();
//        audioResponse.setSessionId(sqlResponse.getSessionId());
//        audioResponse.setAudio(audio);
//        audioResponse.setDescription(sqlResponse.getDescription());
//        audioResponse.setExecutedQuery(sqlResponse.getExecutedQuery());
//        audioResponse.setResponse(sqlResponse.getResponse());
//        audioResponse.setQuery(sqlResponse.getQuery());
//        audioResponse.setRenderedResult(sqlResponse.getRenderedResult());
//        return audioResponse;
//    }

    static Properties getStreamsConfiguration(final String bootstrapServers, final String key, final String secret) {
        final Properties streamsConfiguration = new Properties();
        streamsConfiguration.put(StreamsConfig.APPLICATION_ID_CONFIG, "quickstart-build-query");
        streamsConfiguration.put(StreamsConfig.CLIENT_ID_CONFIG, "quickstart-build-query");
        streamsConfiguration.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        if (key != null && secret != null) {
            streamsConfiguration.put(StreamsConfig.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
            streamsConfiguration.put(SaslConfigs.SASL_MECHANISM, "PLAIN");
            final String jaasConfig = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\""
                    + key + "\" password=\"" + secret + "\";";
            streamsConfiguration.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig);
        }

        streamsConfiguration.put("schema.registry.url", schemaRegistryUrl);
        final String basicAuthCredentialsSource = "USER_INFO";
        streamsConfiguration.put("basic.auth.credentials.source", basicAuthCredentialsSource);
        streamsConfiguration.put("schema.registry.basic.auth.user.info", schemaRegistryKey + ":" + schemaRegistrySecret);

        streamsConfiguration.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);
        streamsConfiguration.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.StringSerde.class);

        streamsConfiguration.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 10 * 1000);
        streamsConfiguration.put(StreamsConfig.STATE_DIR_CONFIG, TestUtils.tempDirectory().getAbsolutePath());
        return streamsConfiguration;
    }

}
