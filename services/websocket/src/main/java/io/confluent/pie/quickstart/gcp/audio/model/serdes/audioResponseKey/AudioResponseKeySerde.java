package io.confluent.pie.quickstart.gcp.audio.model.serdes.audioResponseKey;

import io.confluent.pie.quickstart.gcp.audio.model.AudioResponseKey;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractSerde;
import java.util.Map;

public class AudioResponseKeySerde extends AbstractSerde<AudioResponseKey, AudioResponseKeySerializer, AudioResponseKeyDeserializer> {

    public AudioResponseKeySerde() {
        super(AudioResponseKeySerializer::new, AudioResponseKeyDeserializer::new);
    }

    public AudioResponseKeySerde(Map<String, ?> configs, boolean isKey) {
        super(AudioResponseKeySerializer::new, AudioResponseKeyDeserializer::new, configs, isKey);
    }
}
