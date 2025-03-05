package io.confluent.pie.quickstart.gcp.audio.kafka;

import org.springframework.context.annotation.Configuration;

@Configuration
public class KafkaTopicConfig {

    public String getAudioRequestTopic() {
        return "audio_request";
    }

    public String getInputRequestTopic() {
        return "input_request";
    }

    public String getAudioResponseTopic() {
        return "audio_response";
    }

}
