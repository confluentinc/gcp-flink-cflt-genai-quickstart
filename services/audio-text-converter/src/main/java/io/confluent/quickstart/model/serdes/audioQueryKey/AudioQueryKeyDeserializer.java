package io.confluent.quickstart.model.serdes.audioQueryKey;

import io.confluent.quickstart.model.AudioQueryKey;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class AudioQueryKeyDeserializer extends AbstractDeserializer<AudioQueryKey> {

    public AudioQueryKeyDeserializer() {
        super((AudioQueryKey.class));
    }
}
