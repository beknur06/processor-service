-- traction_force: TE33A max traction = throttle×500 = 500 kN max
UPDATE alert_thresholds SET warning_high = 420.0, critical_high = 470.0
WHERE param_name = 'traction_force';

-- brake_force: max braking force lerp target = 350 kN
UPDATE alert_thresholds SET warning_high = 280.0, critical_high = 320.0
WHERE param_name = 'brake_force';

-- boost_pressure: idle target = 1013 mbar, never drops below ~1000
-- Low boost (below normal idle) indicates turbo/intake issue
UPDATE alert_thresholds SET warning_low = 950.0, critical_low = 850.0, warning_high = NULL, critical_high = NULL
WHERE param_name = 'boost_pressure';

-- main_reservoir_pressure: during braking target = 0.78 bar, never reaches 0.65
-- Warning fires when pressure drops further than normal braking
UPDATE alert_thresholds SET warning_low = 0.74, critical_low = 0.68
WHERE param_name = 'main_reservoir_pressure';

-- fuel_rate: TE33A max = 30 + 1.0×320 = 350 L/h — warning was 380 (above max)
UPDATE alert_thresholds SET warning_high = 320.0, critical_high = 345.0
WHERE param_name = 'fuel_rate';

-- fuel_temp: max = ambient(30) + 10 + load(1.0)×20 = 60°C — warning was 70 (unreachable)
UPDATE alert_thresholds SET warning_high = 50.0, critical_high = 58.0
WHERE param_name = 'fuel_temp';

-- engine_rpm critical low: stopped/idle target = 600, critical was ≤400 (never reached)
UPDATE alert_thresholds SET critical_low = 490.0
WHERE param_name = 'engine_rpm';

-- battery_voltage: simulator always produces 107–113 V — warning was ≤95 (impossible)
-- Tight bounds to catch noise spikes
UPDATE alert_thresholds SET warning_low = 107.0, critical_low = 105.0
WHERE param_name = 'battery_voltage';

-- dc_bus_voltage: KZ8A range = 1800 ± 50 = 1750–1850 V
-- Old bounds (≤1500 / ≥1950) are well outside the operating range
UPDATE alert_thresholds SET
    warning_low  = 1760.0, critical_low  = 1752.0,
    warning_high = 1840.0, critical_high = 1848.0
WHERE param_name = 'dc_bus_voltage';

-- transformer_oil_temp: max = 35 + load×45 + ambient×0.15 ≈ 84.5°C at full load+heat
-- Old warning=85 was just above the reachable ceiling and has no anomaly
UPDATE alert_thresholds SET warning_high = 78.0, critical_high = 88.0
WHERE param_name = 'transformer_oil_temp';

-- sand_level: was never decremented by simulator — will be fixed in simulator code
-- Keep thresholds but adjust to meaningful values
UPDATE alert_thresholds SET warning_low = 30.0, critical_low = 15.0
WHERE param_name = 'sand_level';
