package io.confluent.quickstart.model.serdes.summaryResult;

import io.confluent.quickstart.model.SummaryResult;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class SummaryResultDeserializer extends AbstractDeserializer<SummaryResult> {

    public SummaryResultDeserializer() {
        super((SummaryResult.class));
    }

}
