package io.confluent.pie.quickstart.gcp.audio.model.serdes.response;

import io.confluent.pie.quickstart.gcp.audio.model.AudioResponse;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractSerde;
import java.util.Map;

public class AudioResponseSerde extends AbstractSerde<AudioResponse, AudioResponseSerializer, AudioResponseDeserializer> {

    public AudioResponseSerde() {
        super(AudioResponseSerializer::new, AudioResponseDeserializer::new);
    }

    public AudioResponseSerde(Map<String, ?> configs, boolean isKey) {
        super(AudioResponseSerializer::new, AudioResponseDeserializer::new, configs, isKey);
    }

}
