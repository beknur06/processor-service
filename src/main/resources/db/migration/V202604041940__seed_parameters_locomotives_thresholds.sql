ALTER TABLE alert_thresholds ALTER COLUMN id SET DEFAULT gen_random_uuid();

INSERT INTO alert_thresholds (
    param_name,
    display_name,
    warning_low,
    warning_high,
    critical_low,
    critical_high,
    warning_recommendation,
    critical_recommendation,
    applicable_to,
    enabled
) VALUES
      -- BOTH
      ('speed', 'Скорость', NULL, 110.0, NULL, NULL, NULL, NULL, 'BOTH', TRUE),

      -- TE33A (DIESEL)
      ('traction_force', 'Тяговое усилие', NULL, 750.0, NULL, 800.0, NULL, NULL, 'DIESEL', TRUE),
      ('brake_force', 'Тормозное усилие', NULL, 450.0, NULL, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('coolant_temp', 'Температура охл. жидкости', NULL, 88.0, NULL, 95.0, NULL, NULL, 'DIESEL', TRUE),
      ('oil_temp', 'Температура масла двигателя', NULL, 90.0, NULL, 100.0, NULL, NULL, 'DIESEL', TRUE),
      ('exhaust_temp', 'Температура выхлопных газов', NULL, 550.0, NULL, 600.0, NULL, NULL, 'DIESEL', TRUE),
      ('traction_motor_temp', 'Температура обмоток ТЭД', NULL, 140.0, NULL, 160.0, NULL, NULL, 'DIESEL', TRUE),
      ('oil_pressure', 'Давление масла двигателя', 0.25, NULL, 0.15, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('brake_pipe_pressure', 'Давление в тормозной магистрали', 0.40, NULL, 0.35, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('boost_pressure', 'Давление наддува', 800.0, NULL, NULL, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('main_reservoir_pressure', 'Давление в главном резервуаре', 0.65, NULL, 0.55, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('fuel_level', 'Уровень топлива', 600.0, NULL, 300.0, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('fuel_rate', 'Расход топлива', NULL, 380.0, NULL, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('fuel_temp', 'Температура топлива', NULL, 70.0, NULL, 80.0, NULL, NULL, 'DIESEL', TRUE),
      ('engine_rpm', 'Обороты дизеля', NULL, 1050.0, 400.0, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('battery_voltage', 'Напряжение АКБ', 95.0, NULL, 85.0, NULL, NULL, NULL, 'DIESEL', TRUE),
      ('sand_level', 'Уровень песка', 20.0, NULL, 10.0, NULL, NULL, NULL, 'DIESEL', TRUE),

      -- KZ8A (ELECTRIC)
      ('transformer_oil_temp', 'Температура масла трансформатора', NULL, 85.0, NULL, 95.0, NULL, NULL, 'ELECTRIC', TRUE),
      ('catenary_voltage', 'Напряжение контактной сети', 21.0, 29.0, 19.0, 31.0, NULL, NULL, 'ELECTRIC', TRUE),
      ('traction_motor_current', 'Ток тягового двигателя', NULL, 1100.0, NULL, 1200.0, NULL, NULL, 'ELECTRIC', TRUE),
      ('dc_bus_voltage', 'Напряжение шины DC', 1500.0, 1950.0, NULL, NULL, NULL, NULL, 'ELECTRIC', TRUE),
      ('battery_voltage', 'Напряжение АКБ', 95.0, NULL, 85.0, NULL, NULL, NULL, 'ELECTRIC', TRUE),
      ('sand_level', 'Уровень песка', 20.0, NULL, 10.0, NULL, NULL, NULL, 'ELECTRIC', TRUE);