package io.confluent.pie.quickstart.gcp.audio.model.serdes.response;

import io.confluent.pie.quickstart.gcp.audio.model.AudioResponse;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractDeserializer;

public class AudioResponseDeserializer extends AbstractDeserializer<AudioResponse> {
    public AudioResponseDeserializer() {
        super(AudioResponse.class);
    }
}
