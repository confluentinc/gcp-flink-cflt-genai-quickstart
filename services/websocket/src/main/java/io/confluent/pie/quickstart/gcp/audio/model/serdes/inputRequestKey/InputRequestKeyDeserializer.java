package io.confluent.pie.quickstart.gcp.audio.model.serdes.inputRequestKey;


import io.confluent.pie.quickstart.gcp.audio.model.InputRequestKey;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractDeserializer;

public class InputRequestKeyDeserializer extends AbstractDeserializer<InputRequestKey> {
    public InputRequestKeyDeserializer() {
        super((InputRequestKey.class));
    }
}
