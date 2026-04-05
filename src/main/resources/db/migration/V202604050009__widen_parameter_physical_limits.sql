-- parameter_definitions.min_val/max_val are used by ingestion-service for hard validation.
-- Current values are normal operating ranges, which causes alert-territory telemetry to be
-- rejected with 400 REJECTED before it can be stored or trigger alerts.
-- Update to physical sensor limits (much wider) so valid-but-degraded readings pass through.

-- Temperatures (°C) — physical sensor range, well beyond any alert threshold
UPDATE parameter_definitions SET min_val = -20,  max_val = 200  WHERE code = 'coolant_temp';
UPDATE parameter_definitions SET min_val = -20,  max_val = 200  WHERE code = 'oil_temp';
UPDATE parameter_definitions SET min_val = 0,    max_val = 900  WHERE code = 'exhaust_temp';
UPDATE parameter_definitions SET min_val = 0,    max_val = 280  WHERE code = 'traction_motor_temp';
UPDATE parameter_definitions SET min_val = -20,  max_val = 160  WHERE code = 'transformer_oil_temp';
UPDATE parameter_definitions SET min_val = -10,  max_val = 120  WHERE code = 'fuel_temp';
UPDATE parameter_definitions SET min_val = -30,  max_val = 60   WHERE code = 'cabin_temp';

-- Pressures (MPa) — allow zero (drained) and above normal operating ceiling
UPDATE parameter_definitions SET min_val = 0,    max_val = 2.0  WHERE code = 'oil_pressure';
UPDATE parameter_definitions SET min_val = 0,    max_val = 1.0  WHERE code = 'brake_pipe_pressure';
UPDATE parameter_definitions SET min_val = 0,    max_val = 1.0  WHERE code = 'brake_cylinder_pressure';
UPDATE parameter_definitions SET min_val = 0,    max_val = 1.5  WHERE code = 'main_reservoir_pressure';

-- Boost pressure (mbar) — from vacuum to high boost
UPDATE parameter_definitions SET min_val = 0,    max_val = 3000 WHERE code = 'boost_pressure';

-- Speed & forces — allow full physical range
UPDATE parameter_definitions SET min_val = 0,    max_val = 200  WHERE code = 'speed';
UPDATE parameter_definitions SET min_val = 0,    max_val = 1200 WHERE code = 'traction_force';
UPDATE parameter_definitions SET min_val = 0,    max_val = 700  WHERE code = 'brake_force';

-- Engine
UPDATE parameter_definitions SET min_val = 0,    max_val = 1300 WHERE code = 'engine_rpm';
UPDATE parameter_definitions SET min_val = 0,    max_val = 600  WHERE code = 'fuel_rate';

-- Electric (KZ8A)
UPDATE parameter_definitions SET min_val = 10,   max_val = 40   WHERE code = 'catenary_voltage';
UPDATE parameter_definitions SET min_val = 0,    max_val = 1800 WHERE code = 'traction_motor_current';
UPDATE parameter_definitions SET min_val = 500,  max_val = 2500 WHERE code = 'dc_bus_voltage';
UPDATE parameter_definitions SET min_val = 0,    max_val = 12000 WHERE code = 'regen_power';

-- Battery voltage — warning threshold is now 107 V (V202604050007); allow down to 60 V
UPDATE parameter_definitions SET min_val = 60,   max_val = 150  WHERE code = 'battery_voltage';

-- Sand level — starts at 0 when fully depleted
UPDATE parameter_definitions SET min_val = 0,    max_val = 100  WHERE code = 'sand_level';
