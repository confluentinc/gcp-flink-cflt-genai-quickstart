package io.confluent.pie.quickstart.gcp.audio.model.serdes.query;

import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import io.confluent.pie.quickstart.gcp.audio.utils.AbstractDeserializer;

public class AudioQueryDeserializer extends AbstractDeserializer<AudioQuery> {

    protected AudioQueryDeserializer() {
        super(AudioQuery.class);
    }
}
