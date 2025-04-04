package io.confluent.quickstart.model.serdes;

import io.confluent.quickstart.model.GeneratedSql;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class GeneratedSqlSerde extends AbstractSerde<GeneratedSql, GeneratedSqlSerializer, GeneratedSqlDeserializer> {

    public GeneratedSqlSerde() {
        super(GeneratedSqlSerializer::new, GeneratedSqlDeserializer::new);
    }

    public GeneratedSqlSerde(Map<String, ?> configs, boolean isKey) {
        super (GeneratedSqlSerializer::new, GeneratedSqlDeserializer::new, configs, isKey);
    }
}
