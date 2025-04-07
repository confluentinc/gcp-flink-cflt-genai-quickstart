package io.confluent.quickstart.model.serdes.sqlResultKey;

import io.confluent.quickstart.model.SqlResultKey;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class SqlResultKeySerde extends AbstractSerde<SqlResultKey, SqlResultKeySerializer, SqlResultKeyDeserializer> {

    public SqlResultKeySerde() {
        super(SqlResultKeySerializer::new, SqlResultKeyDeserializer::new);
    }

    public SqlResultKeySerde(Map<String, ?> configs, boolean isKey) {
        super(SqlResultKeySerializer::new, SqlResultKeyDeserializer::new, configs, isKey);
    }
}
