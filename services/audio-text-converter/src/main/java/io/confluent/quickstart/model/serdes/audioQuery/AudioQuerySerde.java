package io.confluent.quickstart.model.serdes.audioQuery;

import io.confluent.quickstart.model.AudioQuery;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class AudioQuerySerde extends AbstractSerde<AudioQuery, AudioQuerySerializer, AudioQueryDeserializer> {

    public AudioQuerySerde() {
        super(AudioQuerySerializer::new, AudioQueryDeserializer::new);
    }

    public AudioQuerySerde(Map<String, ?> configs, boolean isKey) {
        super(AudioQuerySerializer::new, AudioQueryDeserializer::new, configs, isKey);
    }
}
