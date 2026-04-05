-- Increase penalty multipliers for critical deviations
-- Old values were 1.2–2.5; new values make critical zone punish harder

UPDATE health_param_weights SET penalty_multiplier = 3.0 WHERE param_name = 'coolant_temp';
UPDATE health_param_weights SET penalty_multiplier = 2.5 WHERE param_name = 'oil_temp';
UPDATE health_param_weights SET penalty_multiplier = 3.0 WHERE param_name = 'exhaust_temp';
UPDATE health_param_weights SET penalty_multiplier = 3.0 WHERE param_name = 'traction_motor_temp';
UPDATE health_param_weights SET penalty_multiplier = 2.5 WHERE param_name = 'transformer_oil_temp';
UPDATE health_param_weights SET penalty_multiplier = 3.5 WHERE param_name = 'oil_pressure';
UPDATE health_param_weights SET penalty_multiplier = 3.5 WHERE param_name = 'brake_pipe_pressure';
UPDATE health_param_weights SET penalty_multiplier = 2.0 WHERE param_name = 'main_reservoir_pressure';
UPDATE health_param_weights SET penalty_multiplier = 2.5 WHERE param_name = 'catenary_voltage';
UPDATE health_param_weights SET penalty_multiplier = 2.5 WHERE param_name = 'traction_motor_current';
UPDATE health_param_weights SET penalty_multiplier = 2.0 WHERE param_name = 'dc_bus_voltage';
UPDATE health_param_weights SET penalty_multiplier = 2.0 WHERE param_name = 'battery_voltage';
UPDATE health_param_weights SET penalty_multiplier = 1.5 WHERE param_name = 'fuel_level';
UPDATE health_param_weights SET penalty_multiplier = 2.0 WHERE param_name = 'engine_rpm';
UPDATE health_param_weights SET penalty_multiplier = 1.5 WHERE param_name = 'fuel_rate';
UPDATE health_param_weights SET penalty_multiplier = 1.5 WHERE param_name = 'sand_level';
UPDATE health_param_weights SET penalty_multiplier = 2.0 WHERE param_name = 'boost_pressure';
