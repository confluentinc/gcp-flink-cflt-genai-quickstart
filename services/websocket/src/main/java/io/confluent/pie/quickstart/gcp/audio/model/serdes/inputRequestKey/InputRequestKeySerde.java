package io.confluent.pie.quickstart.gcp.audio.model.serdes.inputRequestKey;

import io.confluent.pie.quickstart.gcp.audio.model.InputRequestKey;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractSerde;
import java.util.Map;

public class InputRequestKeySerde extends AbstractSerde<InputRequestKey, InputRequestKeySerializer, InputRequestKeyDeserializer> {

    public InputRequestKeySerde() {
        super(InputRequestKeySerializer::new, InputRequestKeyDeserializer::new);
    }

    public InputRequestKeySerde(Map<String, ?> configs, boolean isKey) {
        super(InputRequestKeySerializer::new, InputRequestKeyDeserializer::new, configs, isKey);
    }
}
