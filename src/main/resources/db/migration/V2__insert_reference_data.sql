-- 1. Добавляем параметры телеметрии
INSERT INTO parameter_definitions (id, code, name, unit, min_val, max_val) VALUES
    (gen_random_uuid(), 'speed', 'Скорость', 'km/h', 0, 120),
    (gen_random_uuid(), 'traction_force', 'Тяговое усилие', 'kN', 0, 833),
    (gen_random_uuid(), 'brake_force', 'Тормозное усилие', 'kN', 0, 500),
    (gen_random_uuid(), 'throttle_pos', 'Позиция контроллера', 'pos', 0, 32),
    (gen_random_uuid(), 'coolant_temp', 'Температура охл. жидкости', '°C', 70, 85),
    (gen_random_uuid(), 'oil_temp', 'Температура масла двигателя', '°C', 65, 85),
    (gen_random_uuid(), 'exhaust_temp', 'Температура выхлопных газов', '°C', 350, 520),
    (gen_random_uuid(), 'traction_motor_temp', 'Температура обмоток ТЭД', '°C', 60, 120),
    (gen_random_uuid(), 'transformer_oil_temp', 'Температура масла трансформатора', '°C', 40, 75),
    (gen_random_uuid(), 'ambient_temp', 'Температура наружного воздуха', '°C', -50, 50),
    (gen_random_uuid(), 'oil_pressure', 'Давление масла двигателя', 'MPa', 0.3, 0.6),
    (gen_random_uuid(), 'brake_pipe_pressure', 'Давление в тормозной магистрали', 'MPa', 0.45, 0.52),
    (gen_random_uuid(), 'brake_cylinder_pressure', 'Давление в тормозном цилиндре', 'MPa', 0, 0.40),
    (gen_random_uuid(), 'boost_pressure', 'Давление наддува', 'mbar', 900, 1800),
    (gen_random_uuid(), 'main_reservoir_pressure', 'Давление в главном резервуаре', 'MPa', 0.75, 0.90),
    (gen_random_uuid(), 'fuel_level', 'Уровень топлива', 'L', 0, 6000),
    (gen_random_uuid(), 'fuel_rate', 'Расход топлива', 'L/h', 30, 350),
    (gen_random_uuid(), 'fuel_temp', 'Температура топлива', '°C', 20, 60),
    (gen_random_uuid(), 'engine_rpm', 'Обороты дизеля', 'RPM', 600, 1050),
    (gen_random_uuid(), 'catenary_voltage', 'Напряжение контактной сети', 'kV', 21, 29),
    (gen_random_uuid(), 'traction_motor_current', 'Ток тягового двигателя', 'A', 0, 1200),
    (gen_random_uuid(), 'dc_bus_voltage', 'Напряжение шины DC', 'V', 1600, 1900),
    (gen_random_uuid(), 'battery_voltage', 'Напряжение АКБ', 'V', 100, 120),
    (gen_random_uuid(), 'regen_power', 'Мощность рекуперации', 'kW', 0, 7600),
    (gen_random_uuid(), 'sand_level', 'Уровень песка', '%', 30, 100),
    (gen_random_uuid(), 'cabin_temp', 'Температура кабины', '°C', 18, 25),
    (gen_random_uuid(), 'gps_lat', 'Широта', '°', NULL, NULL),
    (gen_random_uuid(), 'gps_lon', 'Долгота', '°', NULL, NULL),
    (gen_random_uuid(), 'odometer', 'Пройденный путь', 'km', NULL, NULL),
    (gen_random_uuid(), 'error_code', 'Код ошибки DTC', 'code', NULL, NULL),
    (gen_random_uuid(), 'signaling_state', 'Сигнал КЛУБ-У / АЛСН', 'enum', NULL, NULL);

-- 2. Регистрируем локомотивы
INSERT INTO locomotives (id, code, model, type, manufactured_at) VALUES
    (gen_random_uuid(), 'KZ8A-0042', 'KZ8A', 'ELECTRIC', '2015-05-12'),
    (gen_random_uuid(), 'TE33A-0150', 'TE33A', 'DIESEL', '2012-08-20'),
    (gen_random_uuid(), 'TE33A-0187', 'TE33A', 'DIESEL', '2014-06-15');

-- 3. Настраиваем пороги для ТЭ33А-0150 (DIESEL)
INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 110.0, NULL, NULL -- Скорость
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'speed';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 750.0, NULL, 800.0 -- Тяговое усилие
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'traction_force';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 450.0, NULL, NULL -- Тормозное усилие
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'brake_force';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 88.0, NULL, 95.0 -- Температура охл. жидкости
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'coolant_temp';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 90.0, NULL, 100.0 -- Температура масла двигателя
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'oil_temp';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 550.0, NULL, 600.0 -- Температура выхлопных газов
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'exhaust_temp';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 140.0, NULL, 160.0 -- Температура обмоток ТЭД
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'traction_motor_temp';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 0.25, NULL, 0.15, NULL -- Давление масла двигателя
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'oil_pressure';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 0.40, NULL, 0.35, NULL -- Давление в тормозной магистрали
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'brake_pipe_pressure';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 800.0, NULL, NULL, NULL -- Давление наддува
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'boost_pressure';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 0.65, NULL, 0.55, NULL -- Давление в главном резервуаре
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'main_reservoir_pressure';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 600.0, NULL, 300.0, NULL -- Уровень топлива
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'fuel_level';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 380.0, NULL, NULL -- Расход топлива
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'fuel_rate';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 70.0, NULL, 80.0 -- Температура топлива
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'fuel_temp';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 1050.0, 400.0, NULL -- Обороты дизеля (Warning: >1050, Critical: <400)
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'engine_rpm';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 95.0, NULL, 85.0, NULL -- Напряжение АКБ
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'battery_voltage';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 20.0, NULL, 10.0, NULL -- Уровень песка
FROM locomotives l, parameter_definitions p WHERE l.code = 'TE33A-0150' AND p.code = 'sand_level';


-- 4. Настраиваем пороги для KZ8A-0042 (ELECTRIC)
INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 110.0, NULL, NULL -- Скорость
FROM locomotives l, parameter_definitions p WHERE l.code = 'KZ8A-0042' AND p.code = 'speed';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 85.0, NULL, 95.0 -- Температура масла трансформатора
FROM locomotives l, parameter_definitions p WHERE l.code = 'KZ8A-0042' AND p.code = 'transformer_oil_temp';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 21.0, 29.0, 19.0, 31.0 -- Напряжение контактной сети
FROM locomotives l, parameter_definitions p WHERE l.code = 'KZ8A-0042' AND p.code = 'catenary_voltage';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, NULL, 1100.0, NULL, 1200.0 -- Ток тягового двигателя
FROM locomotives l, parameter_definitions p WHERE l.code = 'KZ8A-0042' AND p.code = 'traction_motor_current';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 1500.0, 1950.0, NULL, NULL -- Напряжение шины DC
FROM locomotives l, parameter_definitions p WHERE l.code = 'KZ8A-0042' AND p.code = 'dc_bus_voltage';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 95.0, NULL, 85.0, NULL -- Напряжение АКБ
FROM locomotives l, parameter_definitions p WHERE l.code = 'KZ8A-0042' AND p.code = 'battery_voltage';

INSERT INTO threshold_configs (loco_id, param_id, warning_low, warning_high, critical_low, critical_high)
SELECT l.id, p.id, 20.0, NULL, 10.0, NULL -- Уровень песка
FROM locomotives l, parameter_definitions p WHERE l.code = 'KZ8A-0042' AND p.code = 'sand_level';

-- 5. Задаем веса для расчета Health Index
-- Для дизеля (TE33A)
INSERT INTO health_weights (loco_type, param_id, weight)
SELECT 'DIESEL', id, 0.35 FROM parameter_definitions WHERE code = 'coolant_temp';
INSERT INTO health_weights (loco_type, param_id, weight)
SELECT 'DIESEL', id, 0.40 FROM parameter_definitions WHERE code = 'oil_pressure';
INSERT INTO health_weights (loco_type, param_id, weight)
SELECT 'DIESEL', id, 0.25 FROM parameter_definitions WHERE code = 'engine_rpm';

-- Для электровоза (KZ8A)
INSERT INTO health_weights (loco_type, param_id, weight)
SELECT 'ELECTRIC', id, 0.40 FROM parameter_definitions WHERE code = 'catenary_voltage';
INSERT INTO health_weights (loco_type, param_id, weight)
SELECT 'ELECTRIC', id, 0.35 FROM parameter_definitions WHERE code = 'transformer_oil_temp';
INSERT INTO health_weights (loco_type, param_id, weight)
SELECT 'ELECTRIC', id, 0.25 FROM parameter_definitions WHERE code = 'traction_motor_current';