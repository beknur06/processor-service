package kz.ktj.digitaltwin.processor.service;

import kz.ktj.digitaltwin.processor.config.ProcessorProperties;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

// EMA: α × value + (1 − α) × prev  |  α=0.3 by default
@Service
public class EmaService {

    private final double alpha;
    private final boolean enabled;

    private final ConcurrentHashMap<String, ConcurrentHashMap<String, Double>> state
        = new ConcurrentHashMap<>();

    public EmaService(ProcessorProperties properties) {
        this.alpha = properties.getEma().getAlpha();
        this.enabled = properties.getEma().isEnabled();
    }

    public Map<String, Double> smooth(String locomotiveId, Map<String, Double> rawParams) {
        if (!enabled) return new LinkedHashMap<>(rawParams);

        ConcurrentHashMap<String, Double> locoState =
            state.computeIfAbsent(locomotiveId, k -> new ConcurrentHashMap<>());

        Map<String, Double> smoothed = new LinkedHashMap<>();

        for (Map.Entry<String, Double> entry : rawParams.entrySet()) {
            String param = entry.getKey();
            double raw = entry.getValue();
            Double prevEma = locoState.get(param);
            double ema = prevEma == null ? raw : alpha * raw + (1 - alpha) * prevEma;
            ema = Math.round(ema * 100.0) / 100.0;
            locoState.put(param, ema);
            smoothed.put(param, ema);
        }

        return smoothed;
    }

    public void reset(String locomotiveId) {
        state.remove(locomotiveId);
    }

    public int stateSize() {
        return state.values().stream().mapToInt(Map::size).sum();
    }
}
