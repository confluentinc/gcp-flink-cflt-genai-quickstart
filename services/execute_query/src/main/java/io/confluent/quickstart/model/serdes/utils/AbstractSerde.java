/*-
 * Copyright (C) 2024 Confluent, Inc.
 */

package io.confluent.quickstart.model.serdes.utils;

import org.apache.kafka.common.serialization.Serde;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.function.Supplier;

/**
 * Abstract Serde that provides lazy initialization of the serializer and deserializer.
 *
 * @param <T> The type of object that is being serialized and deserialized.
 * @param <S> The serializer type.
 * @param <D> The deserializer type.
 */
public abstract class AbstractSerde<T, S extends AbstractSerializer<T>, D extends AbstractDeserializer<T>> implements Serde<T> {

    private final LazySupplier<S> serializerLazy;
    private final LazySupplier<D> deserializerLazy;
    private Map<String, ?> configs;
    private boolean isKey;

    protected AbstractSerde(Supplier<S> serializerSupplier, Supplier<D> deserializerSupplier) {
        serializerLazy = new LazySupplier<>(serializerSupplier);
        deserializerLazy = new LazySupplier<>(deserializerSupplier);
    }

    protected AbstractSerde(Supplier<S> serializerSupplier,
                            Supplier<D> deserializerSupplier,
                            Map<String, ?> configs,
                            boolean isKey) {
        serializerLazy = new LazySupplier<>(serializerSupplier);
        deserializerLazy = new LazySupplier<>(deserializerSupplier);
        this.configs = configs;
        this.isKey = isKey;
    }

    @Override
    public S serializer() {
        if (!serializerLazy.isInitialized()) {
            serializerLazy.get().configure(Objects.requireNonNullElseGet(configs, HashMap::new), isKey);
        }

        return serializerLazy.get();
    }

    @Override
    public D deserializer() {
        if (!deserializerLazy.isInitialized()) {
            deserializerLazy.get().configure(Objects.requireNonNullElseGet(configs, HashMap::new), isKey);
        }

        return deserializerLazy.get();
    }

    @Override
    public void configure(Map<String, ?> configs, boolean isKey) {
        this.configs = configs;
        this.isKey = isKey;
    }

    @Override
    public void close() {
        if (serializerLazy.isInitialized()) {
            serializerLazy.get().close();
        }

        if (deserializerLazy.isInitialized()) {
            deserializerLazy.get().close();
        }
    }
}
