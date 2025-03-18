package io.confluent.quickstart.model.serdes;

import io.confluent.quickstart.model.AudioResponse;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class AudioResponseSerde extends AbstractSerde<AudioResponse, AudioResponseSerializer, AudioResponseDeserializer> {

    public AudioResponseSerde() {
        super(AudioResponseSerializer::new, AudioResponseDeserializer::new);
    }

    public AudioResponseSerde(Map<String, ?> configs, boolean isKey) {
        super(AudioResponseSerializer::new, AudioResponseDeserializer::new, configs, isKey);
    }

}
