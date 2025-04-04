package io.confluent.quickstart.model.serdes;

import io.confluent.quickstart.model.InputRequest;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class InputRequestDeserializer extends AbstractDeserializer<InputRequest> {
    public InputRequestDeserializer() {
        super((InputRequest.class));
    }
}
