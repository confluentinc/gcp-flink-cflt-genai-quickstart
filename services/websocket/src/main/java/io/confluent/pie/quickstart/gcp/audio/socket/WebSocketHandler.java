package io.confluent.pie.quickstart.gcp.audio.socket;

import io.confluent.pie.quickstart.gcp.audio.kafka.AudioQueryHandler;
import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import lombok.extern.slf4j.Slf4j;
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

    private final AudioQueryHandler audioHandler;

    public WebSocketHandler(@Autowired AudioQueryHandler audioHandler) {
        this.audioHandler = audioHandler;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("Connection established: {}", session.getId());

        // Handle new session
        audioHandler.onNewSession(session);

        super.afterConnectionEstablished(session);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        super.afterConnectionClosed(session, status);

        // Handle session close
        audioHandler.onSessionClose(session);

        log.info("Connection closed: {}", session.getId());
    }

    /**
     * Handle text message
     *
     * @param session Websocket session
     * @param message Text message
     */
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {

        final String payload = message.getPayload();

        // Assuming the payload has additional data before the base64 audio, separated by a comma.
        final String base64 = payload.substring(payload.indexOf(",") + 1);
        final byte[] audio = Base64.getDecoder().decode(base64);

        AudioQuery audioQuery = new AudioQuery(session.getId(), audio);

        log.info("Received audio message from {} of length {}", session.getId() ,audioQuery.getAudio().length);

        audioHandler.onNewMessage(audioQuery);
    }

}
