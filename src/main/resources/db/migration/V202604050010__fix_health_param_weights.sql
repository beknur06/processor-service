-- 1. Remove bogus entries that have no matching simulator parameter
DELETE FROM health_param_weights WHERE param_name IN ('engine_temp', 'vibration', 'battery', 'brake_sys');

-- 2. Fix the one real entry that was seeded with wrong values
UPDATE health_param_weights SET
    display_name        = 'Давление масла',
    weight              = 0.25,
    penalty_multiplier  = 3.5,
    warning_threshold   = 0.4,
    critical_threshold  = 0.7,
    applicable_to       = 'TE33A'
WHERE param_name = 'oil_pressure';

-- 3. Insert the 5 crucial parameters per loco type
--    TE33A: oil_pressure(existing) + coolant_temp + brake_pipe_pressure + traction_motor_temp + main_reservoir_pressure
--    KZ8A:  catenary_voltage + transformer_oil_temp + brake_pipe_pressure + traction_motor_temp + main_reservoir_pressure
INSERT INTO health_param_weights (param_name, display_name, weight, penalty_multiplier, warning_threshold, critical_threshold, applicable_to)
VALUES
    ('brake_pipe_pressure',     'Торм. магистраль',      0.25, 3.5, 0.4, 0.7, 'BOTH'),
    ('traction_motor_temp',     'Обмотки ТЭД',           0.20, 3.0, 0.5, 0.8, 'BOTH'),
    ('main_reservoir_pressure', 'Главный резервуар',      0.10, 2.0, 0.5, 0.8, 'BOTH'),
    ('coolant_temp',            'Охл. жидкость',          0.20, 3.0, 0.5, 0.8, 'TE33A'),
    ('catenary_voltage',        'Напряжение сети',        0.25, 2.5, 0.4, 0.7, 'KZ8A'),
    ('transformer_oil_temp',    'Масло трансформатора',   0.20, 2.5, 0.5, 0.8, 'KZ8A')
ON CONFLICT DO NOTHING;
