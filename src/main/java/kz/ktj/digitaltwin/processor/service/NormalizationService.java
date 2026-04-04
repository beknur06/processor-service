package kz.ktj.digitaltwin.processor.service;

import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Нормализация параметров в диапазон 0..1.
 *
 * 0.0 = идеальное значение (середина нормы)
 * 0.5 = граница внимания
 * 1.0 = критическое значение
 *
 * Для параметров типа «чем ниже — тем хуже» (давление масла, уровень топлива)
 * логика инвертируется.
 *
 * Используется downstream health-index-service для расчёта индекса здоровья.
 */
@Service
public class NormalizationService {

    /**
     * Конфигурация параметра: [normalMin, normalMax, criticalMin, criticalMax]
     * Если criticalMin/Max = NaN, значит направление одностороннее.
     */
    private record ParamRange(double normalMin, double normalMax,
                               double criticalLow, double criticalHigh) {}

    private static final Map<String, ParamRange> RANGES = Map.ofEntries(
        // Движение
        Map.entry("speed",                  new ParamRange(0, 100, -1, 120)),
        Map.entry("traction_force",         new ParamRange(0, 700, -1, 833)),
        Map.entry("brake_force",            new ParamRange(0, 350, -1, 500)),

        // Температуры (выше = хуже)
        Map.entry("coolant_temp",           new ParamRange(70, 85, 50, 95)),
        Map.entry("oil_temp",               new ParamRange(65, 85, 40, 100)),
        Map.entry("exhaust_temp",           new ParamRange(350, 520, 150, 600)),
        Map.entry("traction_motor_temp",    new ParamRange(60, 120, 30, 160)),
        Map.entry("transformer_oil_temp",   new ParamRange(40, 75, 20, 95)),

        // Давления (ниже = хуже для масла; зависит от параметра)
        Map.entry("oil_pressure",           new ParamRange(0.30, 0.60, 0.15, 0.80)),
        Map.entry("brake_pipe_pressure",    new ParamRange(0.45, 0.52, 0.35, 0.60)),
        Map.entry("main_reservoir_pressure",new ParamRange(0.75, 0.90, 0.55, 1.0)),
        Map.entry("boost_pressure",         new ParamRange(900, 1800, 600, 2500)),

        // Топливо (ниже = хуже)
        Map.entry("fuel_level",             new ParamRange(600, 6000, 300, 6500)),
        Map.entry("fuel_rate",              new ParamRange(30, 300, 0, 400)),
        Map.entry("engine_rpm",             new ParamRange(600, 1050, 350, 1100)),

        // Электрика
        Map.entry("catenary_voltage",       new ParamRange(21, 29, 19, 31)),
        Map.entry("traction_motor_current", new ParamRange(0, 1000, -1, 1200)),
        Map.entry("dc_bus_voltage",         new ParamRange(1600, 1900, 1400, 2000)),
        Map.entry("battery_voltage",        new ParamRange(100, 120, 85, 130)),

        // Вспомогательные
        Map.entry("sand_level",             new ParamRange(30, 100, 10, 100))
    );

    /**
     * Нормализует все параметры в 0..1.
     * Параметры без конфигурации пропускаются.
     */
    public Map<String, Double> normalize(Map<String, Double> smoothedParams) {
        Map<String, Double> normalized = new LinkedHashMap<>();

        for (Map.Entry<String, Double> entry : smoothedParams.entrySet()) {
            ParamRange range = RANGES.get(entry.getKey());
            if (range == null) continue; // неизвестный параметр — пропускаем

            double value = entry.getValue();
            double score = computeScore(value, range);
            normalized.put(entry.getKey(), Math.round(score * 1000.0) / 1000.0);
        }

        return normalized;
    }

    /**
     * Вычисляет «степень отклонения» от нормы:
     *  - Внутри [normalMin..normalMax] → 0.0 (всё хорошо)
     *  - Между нормой и критическим → 0.0..1.0 (линейно)
     *  - За критическим → 1.0 (плохо)
     */
    private double computeScore(double value, ParamRange range) {
        // Внутри нормы
        if (value >= range.normalMin && value <= range.normalMax) {
            return 0.0;
        }

        // Ниже нормы
        if (value < range.normalMin) {
            if (range.criticalLow < 0) return 0.0; // нет нижнего критического
            double span = range.normalMin - range.criticalLow;
            if (span <= 0) return 1.0;
            double deviation = range.normalMin - value;
            return Math.min(1.0, deviation / span);
        }

        // Выше нормы
        if (range.criticalHigh <= range.normalMax) return 0.0; // нет верхнего критического
        double span = range.criticalHigh - range.normalMax;
        if (span <= 0) return 1.0;
        double deviation = value - range.normalMax;
        return Math.min(1.0, deviation / span);
    }
}
