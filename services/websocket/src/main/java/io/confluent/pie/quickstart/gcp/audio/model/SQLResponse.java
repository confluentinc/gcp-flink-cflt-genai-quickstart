package io.confluent.pie.quickstart.gcp.audio.model;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SQLResponse {

    private String sessionId;
    private String executedQuery;
    private String response;
    private String description;
    private String query;
    private String renderedResult;

}
