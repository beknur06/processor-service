package kz.ktj.digitaltwin.processor.dto;

import lombok.Builder;
import lombok.Data;

import java.time.Instant;
import java.util.List;
import java.util.Map;

/**
 * Обработанная телеметрия: сглаженные и нормализованные значения.
 * Отправляется в ClickHouse (хранение) и Redis pub/sub (realtime).
 */
@Data
@Builder
public class ProcessedTelemetry {
    private String messageId;
    private String locomotiveId;
    private String locomotiveType;
    private Instant timestamp;
    private Instant processedAt;
    private String phase;

    /** Сырые значения (оригинал) */
    private Map<String, Double> rawParameters;

    /** Сглаженные значения (EMA) */
    private Map<String, Double> smoothedParameters;

    /** Нормализованные 0..1 (для индекса здоровья) */
    private Map<String, Double> normalizedParameters;

    private List<String> activeDtcCodes;
    private Double gpsLat;
    private Double gpsLon;
    private String routeId;
    private Double odometer;
}
