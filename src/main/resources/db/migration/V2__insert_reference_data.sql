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