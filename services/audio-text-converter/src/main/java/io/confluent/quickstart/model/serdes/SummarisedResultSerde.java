package io.confluent.quickstart.model.serdes;

import io.confluent.quickstart.model.SummarisedResult;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class SummarisedResultSerde extends AbstractSerde<SummarisedResult, SummarisedResultSerializer, SummarisedResultDeserializer> {

    public SummarisedResultSerde() {
        super(SummarisedResultSerializer::new, SummarisedResultDeserializer::new);
    }

    public SummarisedResultSerde(Map<String, ?> configs, boolean isKey) {
        super(SummarisedResultSerializer::new, SummarisedResultDeserializer::new, configs, isKey);
    }
}
