package io.confluent.quickstart.model.serdes.generatedSqlKey;

import io.confluent.quickstart.model.GeneratedSqlKey;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class GeneratedSqlKeyDeserializer extends AbstractDeserializer<GeneratedSqlKey> {

    public GeneratedSqlKeyDeserializer() {
        super((GeneratedSqlKey.class));
    }
}
