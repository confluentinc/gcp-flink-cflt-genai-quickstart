package io.confluent.pie.quickstart.gcp.audio.model;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class AudioResponse extends SummarisedResults {

    private String messageId;
    private byte[] audio;

}
