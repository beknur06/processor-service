-- Fix recommendations that were NULL in the original seed

UPDATE alert_thresholds SET
    warning_recommendation  = 'Снизьте нагрузку, проверьте вентиляторы',
    critical_recommendation = 'Остановите поезд, проверьте систему охлаждения'
WHERE param_name = 'coolant_temp';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Контролируйте температуру, снизьте обороты',
    critical_recommendation = 'Остановите дизель, возможен перегрев'
WHERE param_name = 'oil_temp';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Проверьте топливную аппаратуру',
    critical_recommendation = 'Немедленно снизьте нагрузку'
WHERE param_name = 'exhaust_temp';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Снизьте тяговое усилие',
    critical_recommendation = 'Отключите тяговый двигатель'
WHERE param_name = 'traction_motor_temp';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Проверьте вентиляцию трансформатора',
    critical_recommendation = 'Снизьте нагрузку, возможен перегрев обмоток'
WHERE param_name = 'transformer_oil_temp';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Проверьте уровень масла',
    critical_recommendation = 'Остановите дизель! Критическое давление масла'
WHERE param_name = 'oil_pressure';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Проверьте тормозную магистраль на утечки',
    critical_recommendation = 'Экстренное торможение! Утечка воздуха'
WHERE param_name = 'brake_pipe_pressure';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Компрессор не поддерживает давление',
    critical_recommendation = 'Остановитесь, нет запаса воздуха для торможения'
WHERE param_name = 'main_reservoir_pressure';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Нестабильное напряжение, контролируйте ток',
    critical_recommendation = 'Аварийное напряжение сети, снизьте потребление'
WHERE param_name = 'catenary_voltage';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Приближение к пределу, снизьте тягу',
    critical_recommendation = 'Перегрузка ТЭД! Отключите тяговый двигатель'
WHERE param_name = 'traction_motor_current';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Низкий запас топлива, планируйте заправку',
    critical_recommendation = 'Критический уровень топлива!'
WHERE param_name = 'fuel_level';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Низкий заряд АКБ',
    critical_recommendation = 'Критический разряд АКБ'
WHERE param_name = 'battery_voltage';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Мало песка, заправьте при остановке',
    critical_recommendation = 'Критически мало песка, сцепление ухудшено'
WHERE param_name = 'sand_level';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Нестабильные обороты, проверьте регулятор',
    critical_recommendation = 'Аварийные обороты дизеля'
WHERE param_name = 'engine_rpm';

UPDATE alert_thresholds SET
    warning_recommendation  = 'Проверьте напряжение шины DC',
    critical_recommendation = 'Аварийное напряжение шины DC'
WHERE param_name = 'dc_bus_voltage';

-- Add traction_motor_temp for KZ8A (was only seeded for TE33A)
INSERT INTO alert_thresholds (
    param_name, display_name,
    warning_low, warning_high, critical_low, critical_high,
    warning_recommendation, critical_recommendation,
    applicable_to, enabled
)
SELECT
    'traction_motor_temp', 'Температура обмоток ТЭД',
    NULL, 140.0, NULL, 160.0,
    'Снизьте тяговое усилие', 'Отключите тяговый двигатель',
    'KZ8A', TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM alert_thresholds
    WHERE param_name = 'traction_motor_temp' AND applicable_to = 'KZ8A'
);
