package io.confluent.quickstart.model.serdes.inputRequestKey;

import io.confluent.quickstart.model.InputRequestKey;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class InputRequestKeyDeserializer extends AbstractDeserializer<InputRequestKey> {
    public InputRequestKeyDeserializer() {
        super((InputRequestKey.class));
    }
}
