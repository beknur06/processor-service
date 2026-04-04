INSERT INTO health_param_weights (
    param_name, display_name, weight, penalty_multiplier, warning_threshold, critical_threshold, applicable_to
) VALUES
      ('engine_temp', 'Engine temperature', 0.20, 1.5, 0.5, 0.8, 'BOTH'),
      ('oil_pressure', 'Oil pressure',       0.20, 1.5, 0.5, 0.8, 'BOTH'),
      ('vibration',    'Vibration',          0.20, 1.5, 0.5, 0.8, 'BOTH'),
      ('battery',      'Battery',            0.20, 1.5, 0.5, 0.8, 'BOTH'),
      ('brake_sys',    'Brake system',       0.20, 1.5, 0.5, 0.8, 'BOTH');