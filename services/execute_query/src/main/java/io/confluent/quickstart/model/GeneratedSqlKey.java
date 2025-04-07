package io.confluent.quickstart.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Schema(value = """
        {
          "properties": {
            "sessionId": {
              "connect.index": 0,
              "type": "string"
            }
          },
          "required": [
            "sessionId"
          ],
          "title": "Record",
          "type": "object"
        }
        """, refs={})
public class GeneratedSqlKey {
    private String sessionId;
}
