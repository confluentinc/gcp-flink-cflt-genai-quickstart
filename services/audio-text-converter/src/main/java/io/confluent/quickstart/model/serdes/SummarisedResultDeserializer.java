package io.confluent.quickstart.model.serdes;

import io.confluent.quickstart.model.SummarisedResult;
import io.confluent.quickstart.model.serdes.utils.AbstractDeserializer;

public class SummarisedResultDeserializer extends AbstractDeserializer<SummarisedResult> {

    public SummarisedResultDeserializer() {
        super((SummarisedResult.class));
    }

}
