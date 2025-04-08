package io.confluent.pie.quickstart.gcp.audio.model.serdes.audioResponseKey;

import io.confluent.pie.quickstart.gcp.audio.model.AudioResponseKey;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractDeserializer;

public class AudioResponseKeyDeserializer extends AbstractDeserializer<AudioResponseKey> {
    public AudioResponseKeyDeserializer() {
        super((AudioResponseKey.class));
    }
}
