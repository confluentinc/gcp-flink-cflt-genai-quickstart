package io.confluent.quickstart.model;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class AudioResponse extends SummaryResult {

    private byte[] audio;

}
