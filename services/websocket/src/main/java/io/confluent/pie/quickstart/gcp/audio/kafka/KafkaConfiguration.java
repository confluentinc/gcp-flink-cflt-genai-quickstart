package io.confluent.pie.quickstart.gcp.audio.kafka;

import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import io.confluent.pie.quickstart.gcp.audio.model.AudioResponse;
import io.kcache.Cache;
import io.kcache.KafkaCache;
import io.kcache.KafkaCacheConfig;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.Serdes;
import org.jetbrains.annotations.NotNull;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Configuration
@EnableKafka
public class KafkaConfiguration {

    /**
     * Kafka Template for producing audio messages to topic
     *
     * @param kafkaProperties Kafka properties
     * @return Kafka Template
     */
    @Bean
    public KafkaTemplate<String, AudioQuery> kafkaAudioTemplate(KafkaProperties kafkaProperties) {
        final Map<String, Object> producerProperties = kafkaProperties.buildProducerProperties(null);
        return new KafkaTemplate<>(new DefaultKafkaProducerFactory<>(producerProperties));
    }


    /**
     * Kafka Template for producing Text messages to topic
     *
     * @param kafkaProperties Kafka properties
     * @return Kafka Template
     */
    @Bean
    public KafkaTemplate<String, String> kafkaTextTemplate(KafkaProperties kafkaProperties) {
        final Map<String, Object> producerProperties = kafkaProperties.buildProducerProperties(null);
        return new KafkaTemplate<>(new DefaultKafkaProducerFactory<>(producerProperties));
    }

    /**
     * Kafka listener container factory for consuming messages
     *
     * @param kafkaProperties Kafka properties
     * @return Kafka listener container factory
     */
    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, AudioResponse> kafkaListenerContainerFactory(KafkaProperties kafkaProperties) {
        ConcurrentKafkaListenerContainerFactory<String, AudioResponse> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(defaultConsumerFactory(kafkaProperties));
        return factory;
    }

    /**
     * Initialize a KCache bean.
     *
     * @param kafkaProperties Kafka properties
     * @return KCache instance
     */
    @Bean
    public Cache<String, String> kcache(KafkaProperties kafkaProperties) {
        KafkaCacheConfig config = new KafkaCacheConfig(getCacheConfiguration(kafkaProperties));
        Cache<String, String> cache = new KafkaCache<>(config, Serdes.String(), Serdes.String());
        cache.init();
        return cache;
    }

    private ConsumerFactory<String, AudioResponse> defaultConsumerFactory(KafkaProperties kafkaProperties) {
        Map<String, Object> consumerProps = kafkaProperties.buildConsumerProperties(null);
        return new DefaultKafkaConsumerFactory<>(consumerProps);
    }

    @NotNull
    private Map<String, String> getCacheConfiguration(KafkaProperties kafkaProperties) {
        final Map<String, String> cacheConfiguration = new HashMap<>();
        cacheConfiguration.put(KafkaCacheConfig.KAFKACACHE_BOOTSTRAP_SERVERS_CONFIG,
                kafkaProperties.getBootstrapServers().get(0));
        cacheConfiguration.put(KafkaCacheConfig.KAFKACACHE_SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
        cacheConfiguration.put(KafkaCacheConfig.KAFKACACHE_SASL_MECHANISM_CONFIG, "PLAIN");
        cacheConfiguration.put(KafkaCacheConfig.KAFKACACHE_SASL_JAAS_CONFIG_CONFIG,
                "org.apache.kafka.common.security.plain.PlainLoginModule required username='TAQBRB4SGOPN5FTK' password='9JzXnaio0EyRmuttX1JPHOlV5a5y2w8XH5xtLVPzMur86f+fSV35urwD6G2tsi9E';");
        cacheConfiguration.put(KafkaCacheConfig.KAFKACACHE_GROUP_ID_CONFIG,
                "quickstart-cache-group-" + "kcache-topic1" + "-" + UUID.randomUUID());
        cacheConfiguration.put(KafkaCacheConfig.KAFKACACHE_CLIENT_ID_CONFIG,
                "quickstart-cache-" + "kcache-topic1" + "-" + UUID.randomUUID());
        cacheConfiguration.put(KafkaCacheConfig.KAFKACACHE_TOPIC_CONFIG, "kcache-topic1");
        cacheConfiguration.put("kafkacache." + ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, "60000");
        cacheConfiguration.put("kafkacache." + ProducerConfig.BATCH_SIZE_CONFIG, "100000");
        cacheConfiguration.put("kafkacache." + ProducerConfig.LINGER_MS_CONFIG, "20");
        cacheConfiguration.put("kafkacache." + ProducerConfig.COMPRESSION_TYPE_CONFIG, "lz4");
        return cacheConfiguration;
    }
}
