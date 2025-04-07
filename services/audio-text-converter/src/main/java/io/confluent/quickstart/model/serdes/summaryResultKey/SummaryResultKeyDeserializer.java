package io.confluent.quickstart.model.serdes.summaryResultKey;


import io.confluent.quickstart.model.SummaryResultKey;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class SummaryResultKeyDeserializer extends AbstractDeserializer<SummaryResultKey> {
    public SummaryResultKeyDeserializer() {
        super((SummaryResultKey.class));
    }
}
