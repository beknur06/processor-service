package kz.ktj.digitaltwin.processor.service;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import kz.ktj.digitaltwin.processor.dto.ProcessedTelemetry;
import kz.ktj.digitaltwin.processor.dto.TelemetryEnvelope;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;

/**
 * Главный пайплайн обработки телеметрии.
 *
 *  RabbitMQ → [EMA] → [Normalize] → [ClickHouse] + [Redis pub/sub]
 *
 * Каждый шаг изолирован — можно отключить EMA, заменить хранилище и т.д.
 */
@Service
public class ProcessingPipeline {

    private static final Logger log = LoggerFactory.getLogger(ProcessingPipeline.class);

    private final EmaService emaService;
    private final NormalizationService normalizationService;
    private final ClickHouseWriter clickHouseWriter;
    private final RedisPublisher redisPublisher;

    private final Counter processedCounter;
    private final Counter errorCounter;
    private final Timer processingTimer;

    public ProcessingPipeline(
            EmaService emaService,
            NormalizationService normalizationService,
            ClickHouseWriter clickHouseWriter,
            RedisPublisher redisPublisher,
            MeterRegistry meterRegistry) {
        this.emaService = emaService;
        this.normalizationService = normalizationService;
        this.clickHouseWriter = clickHouseWriter;
        this.redisPublisher = redisPublisher;

        this.processedCounter = Counter.builder("processor.messages.processed")
            .register(meterRegistry);
        this.errorCounter = Counter.builder("processor.messages.errors")
            .register(meterRegistry);
        this.processingTimer = Timer.builder("processor.processing.duration")
            .description("End-to-end processing time per message")
            .register(meterRegistry);
    }

    /**
     * Обрабатывает одно входящее сообщение телеметрии.
     */
    public void process(TelemetryEnvelope envelope) {
        processingTimer.record(() -> {
            try {
                Map<String, Double> raw = envelope.getParameters();

                // 1. EMA smoothing
                Map<String, Double> smoothed = emaService.smooth(
                    envelope.getLocomotiveId(), raw);

                // 2. Normalization (0..1)
                Map<String, Double> normalized = normalizationService.normalize(smoothed);

                // 3. Build processed record
                ProcessedTelemetry processed = ProcessedTelemetry.builder()
                    .messageId(envelope.getMessageId())
                    .locomotiveId(envelope.getLocomotiveId())
                    .locomotiveType(envelope.getLocomotiveType())
                    .timestamp(envelope.getTimestamp())
                    .processedAt(Instant.now())
                    .phase(envelope.getPhase())
                    .rawParameters(raw)
                    .smoothedParameters(smoothed)
                    .normalizedParameters(normalized)
                    .activeDtcCodes(envelope.getActiveDtcCodes())
                    .gpsLat(envelope.getGpsLat())
                    .gpsLon(envelope.getGpsLon())
                    .routeId(envelope.getRouteId())
                    .odometer(envelope.getOdometer())
                    .build();

                // 4. Write to ClickHouse (batched, async)
                clickHouseWriter.buffer(processed);

                // 5. Publish to Redis (immediate, for realtime dashboard)
                redisPublisher.publish(processed);

                processedCounter.increment();

                log.debug("Processed [{}] locomotive={} params={} smoothed={}",
                    envelope.getMessageId(),
                    envelope.getLocomotiveId(),
                    raw.size(),
                    smoothed.size());

            } catch (Exception e) {
                errorCounter.increment();
                log.error("Processing failed for [{}]: {}",
                    envelope.getMessageId(), e.getMessage(), e);
            }
        });
    }
}
