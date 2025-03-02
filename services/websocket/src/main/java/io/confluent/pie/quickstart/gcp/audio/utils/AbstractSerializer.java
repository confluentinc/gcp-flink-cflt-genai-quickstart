/*
 * Copyright (C) 2025 Confluent, Inc.
 */

package io.confluent.pie.quickstart.gcp.audio.utils;

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
