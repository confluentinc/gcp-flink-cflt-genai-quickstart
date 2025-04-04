package io.confluent.pie.quickstart.gcp.audio.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SummarisedResults {

    private String sessionId;
    private String summary;

}
