package io.confluent.quickstart.model.serdes.inputRequest;

import io.confluent.quickstart.model.InputRequest;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class InputRequestSerde extends AbstractSerde<InputRequest, InputRequestSerializer, InputRequestDeserializer> {

    public InputRequestSerde() {
        super(InputRequestSerializer::new, InputRequestDeserializer::new);
    }

    public InputRequestSerde(Map<String, ?> configs, boolean isKey) {
        super(InputRequestSerializer::new, InputRequestDeserializer::new, configs, isKey);
    }
}
