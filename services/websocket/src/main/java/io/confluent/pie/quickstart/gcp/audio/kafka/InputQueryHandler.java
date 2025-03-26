package io.confluent.pie.quickstart.gcp.audio.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.confluent.pie.quickstart.gcp.audio.model.Audio;
import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import io.confluent.pie.quickstart.gcp.audio.model.AudioResponse;
import lombok.extern.slf4j.Slf4j;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Base64;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
public class InputQueryHandler {

    private final static ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private final KafkaTemplate<String, AudioQuery> kafkaAudioTemplate;
    private final KafkaTemplate<String, String> kafkaTextTemplate;
    private final KafkaTemplate<String, AudioResponse> kafkaAudioResponseTemplate;
    private final KafkaTopicConfig kafkaTopicConfig;

    public InputQueryHandler(@Autowired KafkaTemplate<String, AudioQuery> kafkaAudioTemplate,
                             @Autowired KafkaTemplate<String, String> kafkaTextTemplate,
                             @Autowired KafkaTemplate<String, AudioResponse> kafkaAudioResponseTemplate,
                             @Autowired KafkaTopicConfig kafkaTopicConfig) {
        this.kafkaAudioTemplate = kafkaAudioTemplate;
        this.kafkaTextTemplate = kafkaTextTemplate;
        this.kafkaAudioResponseTemplate = kafkaAudioResponseTemplate;
        this.kafkaTopicConfig = kafkaTopicConfig;
    }

    /**
     * Handle new session
     *
     * @param session Websocket session
     */
    public void onNewSession(WebSocketSession session) {
        sessions.put(session.getId(), session);
        log.info("New session established: {}", session.getId());
    }

    /**
     * Handle session close
     *
     * @param session Websocket session
     */
    public void onSessionClose(WebSocketSession session) {
        sessions.remove(session.getId());
        log.info("Session closed: {}", session.getId());
    }

    public void onNewTextMessage(String sessionId, String textQuery) {

        final ProducerRecord<String, String> producerRecord = new ProducerRecord<>(kafkaTopicConfig.getInputRequestTopic(),
                sessionId,
                textQuery);

        kafkaTextTemplate.send(producerRecord).whenComplete((recordMetadata, throwable) -> {
            if (throwable != null) {
                log.error("Failed to send text message to Confluent Cloud", throwable);
            }
        });

        //TODO: Below is for testing
//        AudioResponse audioResponse = new AudioResponse();
//        String randomText = generateRandomString(10);
//        audioResponse.setQuery(textQuery);
//        audioResponse.setDescription("test description" + randomText);
//        audioResponse.setRenderedResult("test rendered results-" + randomText);
//        audioResponse.setAudio(returnAudioBytes());
//        audioResponse.setSessionId(sessionId);
//
//        final ProducerRecord<String, AudioResponse> producerTestRecord = new ProducerRecord<>(kafkaTopicConfig.getAudioResponseTopic(),
//                sessionId,
//                audioResponse);
//
//        kafkaAudioResponseTemplate.send(producerTestRecord).whenComplete((recordMetadata, throwable) -> {
//            if (throwable != null) {
//                log.error("Failed to send audio message to Confluent Cloud", throwable);
//            }
//        });
    }

    public void onNewAudioMessage(AudioQuery audioQuery) {

        final ProducerRecord<String, AudioQuery> producerRecord = new ProducerRecord<>(kafkaTopicConfig.getAudioRequestTopic(),
                audioQuery.getSessionId(),
                audioQuery);

        kafkaAudioTemplate.send(producerRecord).whenComplete((recordMetadata, throwable) -> {
            if (throwable != null) {
                log.error("Failed to send audio message to Confluent Cloud", throwable);
            }
        });

        //TODO: Below is for testing
//        AudioResponse audioResponse = new AudioResponse();
//        String randomText = generateRandomString(10);
//        audioResponse.setQuery("test query-" + randomText);
//        audioResponse.setDescription("test description" + randomText);
//        audioResponse.setRenderedResult("test rendered results-" + randomText);
//        audioResponse.setAudio(audioQuery.getAudio());
//        audioResponse.setSessionId(audioQuery.getSessionId());
//
//        final ProducerRecord<String, AudioResponse> producerTestRecord = new ProducerRecord<>(kafkaTopicConfig.getAudioResponseTopic(),
//                audioQuery.getSessionId(),
//                audioResponse);
//
//        kafkaAudioResponseTemplate.send(producerTestRecord).whenComplete((recordMetadata, throwable) -> {
//            if (throwable != null) {
//                log.error("Failed to send audio message to Confluent Cloud", throwable);
//            }
//        });
    }

    /**
     * Handles incoming audio responses from Kafka, logs them, checks for validity,
     * and sends the audio data to the appropriate WebSocket session.
     *
     * @param sessionId the session ID associated with the audio response
     * @param audioResponse the audio response containing the audio data
     */
    @KafkaListener(topics = "#{kafkaTopicConfig.getAudioResponseTopic()}",
                   containerFactory = "kafkaListenerContainerFactory",
                   groupId = "${spring.kafka.consumer.group-id}")
    public void handleResponse(@Header(KafkaHeaders.RECEIVED_KEY) String sessionId,
                               @Payload AudioResponse audioResponse) {
        log.info("Received audio response for session id {}", sessionId);

        if (StringUtils.isEmpty(sessionId)) {
            log.error("Received response with empty session id");
            return;
        }

        if (audioResponse == null || audioResponse.getAudio() == null) {
            log.error("Received response with empty audio");
            return;
        }

        final WebSocketSession session = sessions.get(sessionId);
        if (session == null) {
            log.error("Session not found for id {}", sessionId);
            return;
        }

        try {
            final String dataURL = encodeAudioAsDataURL(audioResponse.getAudio());
            Audio audio = createAudioData(dataURL, audioResponse.getQuery(), audioResponse.getRenderedResult());
            sendMessage(session, audio);
        } catch (IOException e) {
            log.error("Error sending message: {}", e.getMessage(), e);
        }
    }

    private String encodeAudioAsDataURL(byte[] audio) {
        return "data:audio/wav;base64," + Base64.getEncoder().encodeToString(audio);
    }


    private Audio createAudioData(String dataURL, String query, String renderedResult) {
        Audio audio = new Audio();
        audio.setData(dataURL);
        audio.setQuestion(query);
        audio.setResult(renderedResult);
        return audio;
    }

    private void sendMessage(WebSocketSession session, Audio audio) throws IOException {
        String audioJSON = OBJECT_MAPPER.writeValueAsString(audio);
        session.sendMessage(new TextMessage(audioJSON));
        log.info("Sent audio response to session id {}", session.getId());
    }

    //TODO: Below is for testing
//    public static String generateRandomString(int length) {
//        // Initialize a StringBuilder to hold the result
//        StringBuilder sb = new StringBuilder(length);
//
//        // Characters will be chosen from this string
//        String charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
//
//        // Create an instance of Random
//        Random random = new Random();
//
//        // Generate random indexes and append the corresponding character to the StringBuilder
//        for (int i = 0; i < length; i++) {
//            int randomIndex = random.nextInt(charSet.length());
//            sb.append(charSet.charAt(randomIndex));
//        }
//
//        return sb.toString();
//    }

    //TODO: Below is for testing
//    private static byte[] generateSineWave(int frequency, int durationSeconds, int sampleRate, int bitsPerSample) {
//        double amplitude = 32760; // Max amplitude for 16-bit
//        int samples = durationSeconds * sampleRate;
//        byte[] output = new byte[samples * 2]; // 2 bytes per sample (16-bit)
//
//        for (int i = 0; i < samples; i++) {
//            short value = (short) (amplitude * Math.sin(2 * Math.PI * frequency * i / sampleRate));
//            // Little endian
//            output[2 * i] = (byte) (value & 0xFF);
//            output[2 * i + 1] = (byte) ((value >> 8) & 0xFF);
//        }
//
//        return output;
//    }

    //TODO: Below is for testing
//    private static byte[] addWavHeader(byte[] audioBytes) {
//        final int SAMPLE_RATE = 44100;
//        final int NUM_CHANNELS = 1;
//        final int BITS_PER_SAMPLE = 16;
//
//        ByteArrayOutputStream baos = new ByteArrayOutputStream();
//        ByteBuffer buffer = ByteBuffer.allocate(44);
//
//        int totalLength = audioBytes.length + 36;
//        int byteRate = SAMPLE_RATE * NUM_CHANNELS * BITS_PER_SAMPLE / 8;
//
//        buffer.put("RIFF".getBytes());
//        buffer.putInt(totalLength);
//        buffer.put("WAVE".getBytes());
//        buffer.put("fmt ".getBytes());
//        buffer.putInt(16);
//        buffer.putShort((short) 1); // PCM
//        buffer.putShort((short) NUM_CHANNELS);
//        buffer.putInt(SAMPLE_RATE);
//        buffer.putInt(byteRate);
//        buffer.putShort((short) (NUM_CHANNELS * BITS_PER_SAMPLE / 8));
//        buffer.putShort((short) BITS_PER_SAMPLE);
//        buffer.put("data".getBytes());
//        buffer.putInt(audioBytes.length);
//
//        baos.write(buffer.array(), 0, buffer.position());
//        try {
//            baos.write(audioBytes);
//        } catch (IOException e) {
//            System.out.println("Error writing WAV data: " + e.getMessage());
//        }
//
//        return baos.toByteArray();
//    }

    //TODO: Below is for testing
//    private static byte[] returnAudioBytes() {
//        final int SAMPLE_RATE = 44100;
//        final int BITS_PER_SAMPLE = 16;
//        final int DURATION_SECONDS = 2;
//        final int FREQUENCY = 440;
//        byte[] rawAudioBytes = generateSineWave(FREQUENCY, DURATION_SECONDS, SAMPLE_RATE, BITS_PER_SAMPLE);
//        byte[] wavBytes = addWavHeader(rawAudioBytes);
//        return wavBytes;
//    }
}
