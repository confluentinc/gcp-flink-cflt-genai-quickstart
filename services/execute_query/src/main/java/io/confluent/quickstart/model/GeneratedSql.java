package io.confluent.quickstart.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@Schema(value = """
        {
          "properties": {
            "session_id": {
              "connect.index": 0,
              "type": "string"
            },
            "sql_request": {
              "connect.index": 1,
              "oneOf": [
                {
                  "type": "null"
                },
                {
                  "type": "string"
                }
              ]
            }
          },
          "required": [
            "session_id"
          ],
          "title": "Record",
          "type": "object"
        }
        """, refs = {})
public class GeneratedSql {

    private String sessionId;
    private String sqlRequest;
}
