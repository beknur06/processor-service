package kz.ktj.digitaltwin.processor.service;

import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class NormalizationService {

    private record ParamRange(double normalMin, double normalMax,
                               double criticalLow, double criticalHigh) {}

    private static final Map<String, ParamRange> RANGES = Map.ofEntries(
        Map.entry("speed",                   new ParamRange(0, 100, -1, 120)),
        Map.entry("traction_force",          new ParamRange(0, 700, -1, 833)),
        Map.entry("brake_force",             new ParamRange(0, 350, -1, 500)),
        Map.entry("coolant_temp",            new ParamRange(60, 90, 40, 105)),
        Map.entry("oil_temp",                new ParamRange(65, 85, 40, 100)),
        Map.entry("exhaust_temp",            new ParamRange(350, 520, 150, 600)),
        Map.entry("traction_motor_temp",     new ParamRange(60, 120, 30, 160)),
        Map.entry("transformer_oil_temp",    new ParamRange(40, 75, 20, 95)),
        Map.entry("oil_pressure",            new ParamRange(0.30, 0.60, 0.15, 0.80)),
        Map.entry("brake_pipe_pressure",     new ParamRange(0.45, 0.52, 0.35, 0.60)),
        Map.entry("main_reservoir_pressure", new ParamRange(0.75, 0.90, 0.55, 1.0)),
        Map.entry("boost_pressure",          new ParamRange(900, 1800, 600, 2500)),
        Map.entry("fuel_level",              new ParamRange(20, 100, 10, 100)),
        Map.entry("fuel_rate",               new ParamRange(30, 300, 0, 400)),
        Map.entry("engine_rpm",              new ParamRange(600, 1050, 350, 1100)),
        Map.entry("catenary_voltage",        new ParamRange(21, 29, 19, 31)),
        Map.entry("traction_motor_current",  new ParamRange(0, 1000, -1, 1200)),
        Map.entry("dc_bus_voltage",          new ParamRange(1600, 1900, 1400, 2000)),
        Map.entry("battery_voltage",         new ParamRange(100, 120, 85, 130)),
        Map.entry("sand_level",              new ParamRange(30, 100, 10, 100))
    );

    public Map<String, Double> normalize(Map<String, Double> smoothedParams) {
        Map<String, Double> normalized = new LinkedHashMap<>();
        for (Map.Entry<String, Double> entry : smoothedParams.entrySet()) {
            ParamRange range = RANGES.get(entry.getKey());
            if (range == null) continue;
            double score = computeScore(entry.getValue(), range);
            normalized.put(entry.getKey(), Math.round(score * 1000.0) / 1000.0);
        }
        return normalized;
    }

    private double computeScore(double value, ParamRange range) {
        if (value >= range.normalMin() && value <= range.normalMax()) return 0.0;

        if (value < range.normalMin()) {
            if (range.criticalLow() < 0) return 0.0;
            double span = range.normalMin() - range.criticalLow();
            if (span <= 0) return 1.0;
            return Math.min(1.0, (range.normalMin() - value) / span);
        }

        if (range.criticalHigh() <= range.normalMax()) return 0.0;
        double span = range.criticalHigh() - range.normalMax();
        if (span <= 0) return 1.0;
        return Math.min(1.0, (value - range.normalMax()) / span);
    }
}
