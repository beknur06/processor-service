package kz.ktj.digitaltwin.processor.service;

import kz.ktj.digitaltwin.processor.config.ProcessorProperties;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Exponential Moving Average (EMA) сглаживание.
 *
 * Формула: EMA_t = α × value_t + (1 − α) × EMA_{t−1}
 *
 * α = 0.3 означает:
 *   - 30% вес нового значения, 70% — предыдущего сглаженного
 *   - Одиночный выброс (шум датчика) сглаживается на 70%
 *   - Реальный тренд догоняется за ~10 тиков
 *
 * Состояние хранится в памяти per locomotive, per parameter.
 * При рестарте сервиса первое значение берётся как начальное (cold start).
 */
@Service
public class EmaService {

    private final double alpha;
    private final boolean enabled;

    /**
     * Nested map: locomotiveId → paramName → lastEmaValue
     */
    private final ConcurrentHashMap<String, ConcurrentHashMap<String, Double>> state
        = new ConcurrentHashMap<>();

    public EmaService(ProcessorProperties properties) {
        this.alpha = properties.getEma().getAlpha();
        this.enabled = properties.getEma().isEnabled();
    }

    /**
     * Применяет EMA ко всем параметрам сообщения.
     *
     * @param locomotiveId ID локомотива
     * @param rawParams    сырые значения
     * @return сглаженные значения (новый Map)
     */
    public Map<String, Double> smooth(String locomotiveId, Map<String, Double> rawParams) {
        if (!enabled) return new LinkedHashMap<>(rawParams);

        ConcurrentHashMap<String, Double> locoState =
            state.computeIfAbsent(locomotiveId, k -> new ConcurrentHashMap<>());

        Map<String, Double> smoothed = new LinkedHashMap<>();

        for (Map.Entry<String, Double> entry : rawParams.entrySet()) {
            String param = entry.getKey();
            double raw = entry.getValue();

            Double prevEma = locoState.get(param);
            double ema;

            if (prevEma == null) {
                // Cold start: первое значение = EMA
                ema = raw;
            } else {
                ema = alpha * raw + (1 - alpha) * prevEma;
            }

            // Округляем до 2 знаков
            ema = Math.round(ema * 100.0) / 100.0;

            locoState.put(param, ema);
            smoothed.put(param, ema);
        }

        return smoothed;
    }

    /**
     * Сбросить состояние EMA для локомотива (при перезапуске сессии).
     */
    public void reset(String locomotiveId) {
        state.remove(locomotiveId);
    }

    public int stateSize() {
        return state.values().stream().mapToInt(Map::size).sum();
    }
}
