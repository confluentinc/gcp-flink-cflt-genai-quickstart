package io.confluent.pie.quickstart.gcp.audio.model;


import io.confluent.kafka.schemaregistry.annotations.Schema;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
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
public class AudioResponseKey {
    private String sessionId;
}
