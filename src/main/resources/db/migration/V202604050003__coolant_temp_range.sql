-- Widen coolant_temp normal range from [70, 85] to [60, 90]
UPDATE parameter_definitions
SET min_val = 60,
    max_val = 90
WHERE code = 'coolant_temp';
