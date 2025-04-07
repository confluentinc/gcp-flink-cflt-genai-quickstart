package io.confluent.quickstart.model.serdes.sqlResult;

import io.confluent.quickstart.model.SqlResult;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class SqlResultDeserializer extends AbstractDeserializer<SqlResult> {

    public SqlResultDeserializer() {
        super((SqlResult.class));
    }
}
