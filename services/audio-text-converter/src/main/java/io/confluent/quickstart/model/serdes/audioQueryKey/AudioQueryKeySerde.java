package io.confluent.quickstart.model.serdes.audioQueryKey;

import io.confluent.quickstart.model.AudioQueryKey;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class AudioQueryKeySerde extends AbstractSerde<AudioQueryKey, AudioQueryKeySerializer, AudioQueryKeyDeserializer> {

    public AudioQueryKeySerde() {
        super(AudioQueryKeySerializer::new, AudioQueryKeyDeserializer::new);
    }

    public AudioQueryKeySerde(Map<String, ?> configs, boolean isKey) {
        super(AudioQueryKeySerializer::new, AudioQueryKeyDeserializer::new, configs, isKey);
    }
}
