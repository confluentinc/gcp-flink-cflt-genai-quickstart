package io.confluent.quickstart.model.serdes.summaryResultKey;

import io.confluent.quickstart.model.SummaryResultKey;
import io.confluent.quickstart.model.serdes.utils.AbstractSerde;
import java.util.Map;

public class SummaryResultKeySerde extends AbstractSerde<SummaryResultKey, SummaryResultKeySerializer, SummaryResultKeyDeserializer> {

    public SummaryResultKeySerde() {
        super(SummaryResultKeySerializer::new, SummaryResultKeyDeserializer::new);
    }

    public SummaryResultKeySerde(Map<String, ?> configs, boolean isKey) {
        super(SummaryResultKeySerializer::new, SummaryResultKeyDeserializer::new, configs, isKey);
    }
}
