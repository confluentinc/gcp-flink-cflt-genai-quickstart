package io.confluent.pie.quickstart.gcp.audio.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.confluent.pie.quickstart.gcp.audio.model.Audio;
import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import io.confluent.pie.quickstart.gcp.audio.model.AudioResponse;
import io.confluent.pie.quickstart.gcp.audio.model.InputRequest;
import io.confluent.pie.quickstart.gcp.audio.model.InputRequestKey;
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
import java.io.IOException;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Service
public class InputQueryHandler {

    private final static ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private final KafkaTemplate<InputRequestKey, AudioQuery> kafkaAudioTemplate;
    private final KafkaTemplate<InputRequestKey, InputRequest> kafkaTextTemplate;
    private final KafkaTopicConfig kafkaTopicConfig;

    public InputQueryHandler(@Autowired KafkaTemplate<InputRequestKey, AudioQuery> kafkaAudioTemplate,
                             @Autowired KafkaTemplate<InputRequestKey, InputRequest> kafkaTextTemplate,
                             @Autowired KafkaTopicConfig kafkaTopicConfig) {
        this.kafkaAudioTemplate = kafkaAudioTemplate;
        this.kafkaTextTemplate = kafkaTextTemplate;
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

    public void onNewTextMessage(String sessionId, InputRequest inputRequest) {
        inputRequest.setSessionId(sessionId);
        InputRequestKey inputRequestKey = new InputRequestKey();
        inputRequestKey.setSessionId(sessionId);

        final ProducerRecord<InputRequestKey, InputRequest> producerRecord = new ProducerRecord<>(kafkaTopicConfig.getInputRequestTopic(),
                inputRequestKey,
                inputRequest);

        kafkaTextTemplate.send(producerRecord).whenComplete((recordMetadata, throwable) -> {
            if (throwable != null) {
                log.error("Failed to send text message to Confluent Cloud", throwable);
            }
        });
    }

    public void onNewAudioMessage(AudioQuery audioQuery) {

        InputRequestKey inputRequestKey = new InputRequestKey();
        inputRequestKey.setSessionId(audioQuery.getSessionId());

        final ProducerRecord<InputRequestKey, AudioQuery> producerRecord = new ProducerRecord<>(kafkaTopicConfig.getAudioRequestTopic(),
                inputRequestKey,
                audioQuery);

        kafkaAudioTemplate.send(producerRecord).whenComplete((recordMetadata, throwable) -> {
            if (throwable != null) {
                log.error("Failed to send audio message to Confluent Cloud", throwable);
            }
        });
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
            Audio audio = createAudioData(dataURL, audioResponse.getSummary());
            sendMessage(session, audio);
        } catch (IOException e) {
            log.error("Error sending message: {}", e.getMessage(), e);
        }
    }

    private String encodeAudioAsDataURL(byte[] audio) {
        return "data:audio/wav;base64," + Base64.getEncoder().encodeToString(audio);
    }


    private Audio createAudioData(String dataURL, String summary) {
        Audio audio = new Audio();
        audio.setData(dataURL);
        audio.setResult(summary);
        return audio;
    }

    private void sendMessage(WebSocketSession session, Audio audio) throws IOException {
        String audioJSON = OBJECT_MAPPER.writeValueAsString(audio);
        session.sendMessage(new TextMessage(audioJSON));
        log.info("Sent audio response to session id {}", session.getId());
    }

}
