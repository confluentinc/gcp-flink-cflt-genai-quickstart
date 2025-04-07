package io.confluent.quickstart.model.serdes.inputRequestKey;

import io.confluent.quickstart.model.InputRequestKey;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class InputRequestKeySerde extends AbstractSerde<InputRequestKey, InputRequestKeySerializer, InputRequestKeyDeserializer> {

    public InputRequestKeySerde() {
        super(InputRequestKeySerializer::new, InputRequestKeyDeserializer::new);
    }

    public InputRequestKeySerde(Map<String, ?> configs, boolean isKey) {
        super(InputRequestKeySerializer::new, InputRequestKeyDeserializer::new, configs, isKey);
    }
}
