package io.confluent.pie.quickstart.gcp.audio.kafka;

import io.confluent.pie.quickstart.gcp.audio.model.AudioQuery;
import io.confluent.pie.quickstart.gcp.audio.model.AudioResponse;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import java.util.Map;

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
     * Kafka Template for producing Audio Responses messages to topic
     *
     * @param kafkaProperties Kafka properties
     * @return Kafka Template
     */
    @Bean
    public KafkaTemplate<String, AudioResponse> kafkaAudioResponseTemplate(KafkaProperties kafkaProperties) {
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

    private ConsumerFactory<String, AudioResponse> defaultConsumerFactory(KafkaProperties kafkaProperties) {
        Map<String, Object> consumerProps = kafkaProperties.buildConsumerProperties(null);
        return new DefaultKafkaConsumerFactory<>(consumerProps);
    }
}
