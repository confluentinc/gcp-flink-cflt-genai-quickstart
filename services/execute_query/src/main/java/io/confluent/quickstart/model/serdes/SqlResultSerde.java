package io.confluent.quickstart.model.serdes;

import io.confluent.quickstart.model.SqlResult;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class SqlResultSerde extends AbstractSerde<SqlResult,SqlResultSerializer, SqlResultDeserializer> {

    public SqlResultSerde() {
        super(SqlResultSerializer::new, SqlResultDeserializer::new);
    }

    public SqlResultSerde(Map<String, ?> configs, boolean isKey) {
        super(SqlResultSerializer::new, SqlResultDeserializer::new, configs, isKey);
    }
}
