package io.confluent.quickstart.model.serdes;


import io.confluent.quickstart.model.AudioResponse;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class AudioResponseDeserializer extends AbstractDeserializer<AudioResponse> {
    public AudioResponseDeserializer() {
        super(AudioResponse.class);
    }
}
