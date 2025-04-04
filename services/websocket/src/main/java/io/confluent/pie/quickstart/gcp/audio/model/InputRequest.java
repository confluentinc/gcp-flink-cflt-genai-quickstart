package io.confluent.pie.quickstart.gcp.audio.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class InputRequest {

    private String sessionId;
    private String request;

}
