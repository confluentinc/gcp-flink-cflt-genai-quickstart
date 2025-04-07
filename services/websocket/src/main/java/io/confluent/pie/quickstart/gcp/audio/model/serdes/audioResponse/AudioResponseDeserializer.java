package io.confluent.pie.quickstart.gcp.audio.model.serdes.audioResponse;

import io.confluent.pie.quickstart.gcp.audio.model.AudioResponse;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractDeserializer;

public class AudioResponseDeserializer extends AbstractDeserializer<AudioResponse> {
    public AudioResponseDeserializer() {
        super(AudioResponse.class);
    }
}
