package io.confluent.pie.quickstart.gcp.audio.model;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class Message {
    private String messageId;
    private String type;
    private String content;
    private String timestamp;
}
