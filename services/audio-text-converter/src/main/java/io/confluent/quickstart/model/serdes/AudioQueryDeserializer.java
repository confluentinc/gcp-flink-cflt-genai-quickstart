package io.confluent.quickstart.model.serdes;

import io.confluent.quickstart.model.AudioQuery;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class AudioQueryDeserializer extends AbstractDeserializer<AudioQuery> {

    protected AudioQueryDeserializer() {
        super(AudioQuery.class);
    }
}
