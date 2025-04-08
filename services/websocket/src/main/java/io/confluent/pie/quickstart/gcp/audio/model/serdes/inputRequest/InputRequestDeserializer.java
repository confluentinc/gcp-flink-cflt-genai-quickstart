package io.confluent.pie.quickstart.gcp.audio.model.serdes.inputRequest;


import io.confluent.pie.quickstart.gcp.audio.model.InputRequest;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractDeserializer;

public class InputRequestDeserializer extends AbstractDeserializer<InputRequest> {
    public InputRequestDeserializer() {
        super((InputRequest.class));
    }
}
