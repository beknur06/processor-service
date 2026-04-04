-- Fix 1: applicable_to used locomotive model codes ("TE33A"/"KZ8A") in code
--         but the seed used Locomotive.Type enum names ("DIESEL"/"ELECTRIC").
--         Align DB values to match what AlertEvaluator receives from TelemetryEnvelope.
UPDATE alert_thresholds SET applicable_to = 'TE33A'  WHERE applicable_to = 'DIESEL';
UPDATE alert_thresholds SET applicable_to = 'KZ8A'   WHERE applicable_to = 'ELECTRIC';

-- Fix 2: fuel_level was changed from raw litres to percentage (0-100 %).
--         Old thresholds: warning_low=600 L, critical_low=300 L → will never fire.
--         New thresholds: warning_low=20 %, critical_low=10 %.
UPDATE alert_thresholds
SET warning_low  = 20.0,
    critical_low = 10.0
WHERE param_name = 'fuel_level';
