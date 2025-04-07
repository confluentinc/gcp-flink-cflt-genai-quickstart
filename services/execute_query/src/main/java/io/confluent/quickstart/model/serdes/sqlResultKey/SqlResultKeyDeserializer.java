package io.confluent.quickstart.model.serdes.sqlResultKey;

import io.confluent.quickstart.model.SqlResultKey;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class SqlResultKeyDeserializer extends AbstractDeserializer<SqlResultKey> {

    public SqlResultKeyDeserializer() {
        super((SqlResultKey.class));
    }
}
