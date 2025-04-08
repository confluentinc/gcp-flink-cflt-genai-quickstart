/*-
 * Copyright (C) 2024 Confluent, Inc.
 */

package io.confluent.quickstart.model.serdes.utils;

import io.confluent.kafka.serializers.json.KafkaJsonSchemaSerializer;


/**
 * Abstract serializer that provides type information to the KafkaJsonSchemaSerializer.
 *
 * @param <T> The type of object that is being serialized.
 */
public abstract class AbstractSerializer<T> extends KafkaJsonSchemaSerializer<T> {

    protected AbstractSerializer() {
    }

}
