package io.confluent.pie.quickstart.gcp.audio.socket;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.confluent.pie.quickstart.gcp.audio.kafka.InputQueryHandler;
import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import io.confluent.pie.quickstart.gcp.audio.model.InputRequest;
import io.confluent.pie.quickstart.gcp.audio.model.Message;
import lombok.extern.slf4j.Slf4j;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import java.util.Base64;

@Slf4j
@Component
public class WebSocketHandler extends TextWebSocketHandler {

    private static final String AUDIO = "audio";
    private static final String TEXT = "text";
    private final InputQueryHandler inputQueryHandler;

    public WebSocketHandler(@Autowired InputQueryHandler audioHandler) {
        this.inputQueryHandler = audioHandler;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("Connection established: {}", session.getId());

        // Handle new session
        inputQueryHandler.onNewSession(session);

        super.afterConnectionEstablished(session);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        super.afterConnectionClosed(session, status);

        // Handle session close
        inputQueryHandler.onSessionClose(session);

        log.info("Connection closed: {}", session.getId());
    }

    /**
     * Handle text message
     *
     * @param session Websocket session
     * @param message Text message
     */
    @Override
    protected void handleTextMessage(@NotNull WebSocketSession session, TextMessage message) {
        final String payload = message.getPayload();
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            Message parsedMessage = objectMapper.readValue(payload, Message.class);

            if (TEXT.equals(parsedMessage.getType())) {

                InputRequest inputRequest = new InputRequest(session.getId(), parsedMessage.getContent());

                log.info("Received text message from {} of length {}", session.getId(), inputRequest.getRequest().length());

                inputQueryHandler.onNewTextMessage(session.getId(), inputRequest);

            } else if (AUDIO.equals(parsedMessage.getType())) {

                // Assuming the payload has additional data before the base64 audio, separated by a comma.
                final String base64 = parsedMessage.getContent().substring(parsedMessage.getContent().indexOf(",") + 1);
                final byte[] audio = Base64.getDecoder().decode(base64);

                AudioQuery audioQuery = new AudioQuery(session.getId(), audio);

                log.info("Received audio message from session {} of length {}", session.getId(), audioQuery.getAudio().length);

                inputQueryHandler.onNewAudioMessage(audioQuery);
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }
}
