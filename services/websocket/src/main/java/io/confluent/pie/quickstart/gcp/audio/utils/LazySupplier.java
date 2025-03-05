/*
 * Copyright (C) 2025 Confluent, Inc.
 */

package io.confluent.pie.quickstart.gcp.audio.utils;

import java.util.function.Supplier;

/**
 * Provides support for lazy initialization.
 *
 * @param <T> The type of object that is being lazily initialized.
 */
public class LazySupplier<T> implements Supplier<T> {
    private final Supplier<T> supplier;
    private T instance;

    public LazySupplier(Supplier<T> supplier) {
        this.supplier = supplier;
    }

    public synchronized T get() {
        if (instance == null) {
            instance = supplier.get();
        }

        return instance;
    }

    public synchronized void reset() {
        instance = null;
    }

    public synchronized boolean isInitialized() {
        return instance != null;
    }

    public static <T> LazySupplier<T> of(Supplier<T> supplier) {
        return new LazySupplier<>(supplier);
    }
}
