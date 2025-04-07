package io.confluent.quickstart.model.serdes.generatedSqlKey;

import io.confluent.quickstart.model.GeneratedSqlKey;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class GeneratedSqlKeySerde extends AbstractSerde<GeneratedSqlKey, GeneratedSqlKeySerializer, GeneratedSqlKeyDeserializer> {

    public GeneratedSqlKeySerde() {
        super(GeneratedSqlKeySerializer::new, GeneratedSqlKeyDeserializer::new);
    }

    public GeneratedSqlKeySerde(Map<String, ?> configs, boolean isKey) {
        super(GeneratedSqlKeySerializer::new, GeneratedSqlKeyDeserializer::new, configs, isKey);
    }
}
