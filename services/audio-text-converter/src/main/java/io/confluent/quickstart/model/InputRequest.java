package io.confluent.quickstart.model;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class InputRequest {

    private String sessionId;
    private String request;

}
