package io.confluent.quickstart.model;

import io.confluent.kafka.schemaregistry.annotations.Schema;

@Schema(value = """
        {
          "properties": {
            "session_id": {
              "connect.index": 0,
              "type": "string"
            }
          },
          "required": [
            "session_id"
          ],
          "title": "Record",
          "type": "object"
        }
        """,
        refs = {}
)
public class InputRequestKey {
    private String sessionId;
}
