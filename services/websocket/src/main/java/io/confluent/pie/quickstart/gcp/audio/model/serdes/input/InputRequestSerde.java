package io.confluent.pie.quickstart.gcp.audio.model.serdes.input;

import io.confluent.pie.quickstart.gcp.audio.model.InputRequest;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractSerde;
import java.util.Map;

public class InputRequestSerde extends AbstractSerde<InputRequest, InputRequestSerializer, InputRequestDeserializer> {

    public InputRequestSerde() {
        super(InputRequestSerializer::new, InputRequestDeserializer::new);
    }

    public InputRequestSerde(Map<String, ?> configs, boolean isKey) {
        super(InputRequestSerializer::new, InputRequestDeserializer::new, configs, isKey);
    }
}
