package kz.ktj.digitaltwin.processor.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import kz.ktj.digitaltwin.processor.dto.ProcessedTelemetry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * Публикация обработанной телеметрии в Redis:
 *
 * 1. SET last_state:{locomotiveId} — последнее полное состояние (для snapshot при WS connect)
 * 2. PUBLISH telemetry:{locomotiveId} — для WebSocket bridge (realtime fan-out к клиентам)
 */
@Service
public class RedisPublisher {

    private static final Logger log = LoggerFactory.getLogger(RedisPublisher.class);

    private final StringRedisTemplate redis;
    private final ObjectMapper objectMapper;
    private final String channelPrefix;
    private final String lastStatePrefix;
    private final Duration ttl;

    public RedisPublisher(
            StringRedisTemplate redis,
            ObjectMapper objectMapper,
            @Value("${redis.channel.telemetry:telemetry}") String channelPrefix,
            @Value("${redis.key.last-state-prefix:last_state}") String lastStatePrefix,
            @Value("${redis.key.ttl-seconds:300}") int ttlSeconds) {
        this.redis = redis;
        this.objectMapper = objectMapper;
        this.channelPrefix = channelPrefix;
        this.lastStatePrefix = lastStatePrefix;
        this.ttl = Duration.ofSeconds(ttlSeconds);
    }

    /**
     * Публикует обработанную телеметрию в Redis.
     */
    public void publish(ProcessedTelemetry telemetry) {
        try {
            String json = objectMapper.writeValueAsString(telemetry);
            String locoId = telemetry.getLocomotiveId();

            // 1. Обновляем last state (для snapshot при подключении нового WS клиента)
            String stateKey = lastStatePrefix + ":" + locoId;
            redis.opsForValue().set(stateKey, json, ttl);

            // 2. Publish в канал (для realtime WebSocket bridge)
            String channel = channelPrefix + ":" + locoId;
            redis.convertAndSend(channel, json);

            log.trace("Published to Redis: {} [{}]", channel, telemetry.getMessageId());

        } catch (JsonProcessingException e) {
            log.error("Failed to serialize telemetry for Redis: {}", e.getMessage());
        } catch (Exception e) {
            log.error("Redis publish failed for {}: {}", telemetry.getLocomotiveId(), e.getMessage());
        }
    }
}
