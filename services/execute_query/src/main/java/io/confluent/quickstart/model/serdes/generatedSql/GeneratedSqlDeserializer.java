package io.confluent.quickstart.model.serdes.generatedSql;

import io.confluent.quickstart.model.GeneratedSql;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class GeneratedSqlDeserializer extends AbstractDeserializer<GeneratedSql> {

    public GeneratedSqlDeserializer() {
        super((GeneratedSql.class));
    }
}
