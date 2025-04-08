package io.confluent.quickstart.model.serdes.summaryResult;

import io.confluent.quickstart.model.SummaryResult;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class SummaryResultSerde extends AbstractSerde<SummaryResult, SummaryResultSerializer, SummaryResultDeserializer> {

    public SummaryResultSerde() {
        super(SummaryResultSerializer::new, SummaryResultDeserializer::new);
    }

    public SummaryResultSerde(Map<String, ?> configs, boolean isKey) {
        super(SummaryResultSerializer::new, SummaryResultDeserializer::new, configs, isKey);
    }
}
