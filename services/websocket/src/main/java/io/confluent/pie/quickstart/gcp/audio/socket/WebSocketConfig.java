package io.confluent.pie.quickstart.gcp.audio.socket;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.standard.ServletServerContainerFactoryBean;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    public static final int MAX_TEXT_MESSAGE_BUFFER_SIZE = 327680;
    public static final String WEBSOCKET_ENDPOINT = "/ws";

    private final WebSocketHandler userRequestHandler;

    public WebSocketConfig(@Autowired WebSocketHandler userRequestHandler) {
        this.userRequestHandler = userRequestHandler;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(userRequestHandler, WEBSOCKET_ENDPOINT)
                .setAllowedOriginPatterns("*");
    }

    @Bean
    public ServletServerContainerFactoryBean createServletServerContainerFactoryBean() {
        ServletServerContainerFactoryBean container = new ServletServerContainerFactoryBean();
        container.setMaxTextMessageBufferSize(MAX_TEXT_MESSAGE_BUFFER_SIZE);
        container.setMaxBinaryMessageBufferSize(MAX_TEXT_MESSAGE_BUFFER_SIZE);
        return container;
    }

}
