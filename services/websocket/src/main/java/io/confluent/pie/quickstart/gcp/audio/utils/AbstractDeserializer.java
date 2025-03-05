/*
 * Copyright (C) 2025 Confluent, Inc.
 */

package io.confluent.pie.quickstart.gcp.audio.utils;


import io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializer;
import java.util.HashMap;
import java.util.Map;

/**
 * Abstract deserializer that provides type information to the KafkaJsonSchemaDeserializer.
 *
 * @param <T> The type of object that is being deserialized.
 */
public abstract class AbstractDeserializer<T> extends KafkaJsonSchemaDeserializer<T> {

    private final Class<T> type;

    protected AbstractDeserializer(Class<T> type) {
        this.type = type;
    }

    @Override
    public void configure(Map<String, ?> props, boolean isKey) {
        // Copy the configuration and add the type information
        final Map<String, Object> configuration = (props != null)
                ? new HashMap<>(props)
                : new HashMap<>();
        configuration.put((isKey) ? "json.key.type" : "json.value.type", type.getName());

        // Delegate to the super class
        super.configure(configuration, isKey);
    }
}
