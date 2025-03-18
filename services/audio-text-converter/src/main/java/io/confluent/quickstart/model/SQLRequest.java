package io.confluent.quickstart.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import io.confluent.kafka.schemaregistry.annotations.SchemaReference;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(value = "{\n" +
        "  \"properties\": {\n" +
        "    \"query\": {\n" +
        "      \"connect.index\": 1,\n" +
        "      \"oneOf\": [\n" +
        "        {\n" +
        "          \"type\": \"null\"\n" +
        "        },\n" +
        "        {\n" +
        "          \"type\": \"string\"\n" +
        "        }\n" +
        "      ]\n" +
        "    },\n" +
        "    \"sessionId\": {\n" +
        "      \"connect.index\": 0,\n" +
        "      \"oneOf\": [\n" +
        "        {\n" +
        "          \"type\": \"null\"\n" +
        "        },\n" +
        "        {\n" +
        "          \"type\": \"string\"\n" +
        "        }\n" +
        "      ]\n" +
        "    }\n" +
        "  },\n" +
        "  \"title\": \"Record\",\n" +
        "  \"type\": \"object\"\n" +
        "}", refs = {@SchemaReference(name = "query.json", subject = "query-value")})
public class SQLRequest {
    private String sessionId;
    private String query;
}
