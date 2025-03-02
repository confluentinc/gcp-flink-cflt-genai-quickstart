package io.confluent.pie.quickstart.gcp.audio.model.serdes.query;

import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractSerde;
import java.util.Map;

public class AudioQuerySerde extends AbstractSerde<AudioQuery, AudioQuerySerializer, AudioQueryDeserializer> {

    public AudioQuerySerde() {
        super(AudioQuerySerializer::new, AudioQueryDeserializer::new);
    }

    public AudioQuerySerde(Map<String, ?> configs, boolean isKey) {
        super(AudioQuerySerializer::new, AudioQueryDeserializer::new, configs, isKey);
    }
}
