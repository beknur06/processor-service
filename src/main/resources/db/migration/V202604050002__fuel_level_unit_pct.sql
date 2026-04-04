-- fuel_level is now published as percentage (0-100%) instead of raw litres
UPDATE parameter_definitions
SET unit    = '%',
    min_val = 0,
    max_val = 100
WHERE code = 'fuel_level';
