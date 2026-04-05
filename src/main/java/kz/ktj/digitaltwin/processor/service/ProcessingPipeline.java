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

        this.processedCounter = Counter.builder("processor.messages.processed").register(meterRegistry);
        this.errorCounter = Counter.builder("processor.messages.errors").register(meterRegistry);
        this.processingTimer = Timer.builder("processor.processing.duration")
            .description("End-to-end processing time per message")
            .register(meterRegistry);
    }

    public void process(TelemetryEnvelope envelope) {
        processingTimer.record(() -> {
            try {
                Map<String, Double> raw = envelope.getParameters();
                Map<String, Double> smoothed = emaService.smooth(envelope.getLocomotiveId(), raw);
                Map<String, Double> normalized = normalizationService.normalize(smoothed);

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

                clickHouseWriter.buffer(processed);
                redisPublisher.publish(processed);
                processedCounter.increment();

                log.debug("Processed [{}] locomotive={} params={} smoothed={}",
                    envelope.getMessageId(), envelope.getLocomotiveId(), raw.size(), smoothed.size());

            } catch (Exception e) {
                errorCounter.increment();
                log.error("Processing failed for [{}]: {}", envelope.getMessageId(), e.getMessage(), e);
            }
        });
    }
}
