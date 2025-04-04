/*-
 * Copyright (C) 2024 Confluent, Inc.
 */

package io.confluent.quickstart.model.serdes.utils;

import lombok.extern.slf4j.Slf4j;
import java.util.function.Supplier;

@Slf4j
public class Retriable {

    /**
     * Retry a supplier function a maximum number of times with a delay between retries
     *
     * @param maxRetries    the maximum number of retries
     * @param delayInSecond the delay between retries in seconds
     * @param supplier      the supplier function to retry
     * @param <T>           the type of the result
     * @return the result of the supplier function
     */
    public static <T> T retry(int maxRetries, int delayInSecond, Supplier<T> supplier) {
        int retries = 0;

        while (retries < maxRetries) {
            try {
                return supplier.get();
            } catch (Exception e) {
                log.warn("Caught exception, retrying");
                retries++;
                if (retries == maxRetries) {
                    log.error("Max retries reached, throwing exception");
                    throw new RuntimeException(e);
                }
                try {
                    Thread.sleep(delayInSecond * 1000L);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                }
            }
        }

        throw new RuntimeException("Should never reach here");
    }
}
