-- HealthParamWeight
CREATE TABLE IF NOT EXISTS health_param_weights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    param_name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    weight DOUBLE PRECISION NOT NULL,
    penalty_multiplier DOUBLE PRECISION NOT NULL DEFAULT 1.5,
    warning_threshold DOUBLE PRECISION NOT NULL DEFAULT 0.5,
    critical_threshold DOUBLE PRECISION NOT NULL DEFAULT 0.8,
    applicable_to TEXT NOT NULL DEFAULT 'BOTH'
);

-- Natural uniqueness for upserts (param + loco applicability)
CREATE UNIQUE INDEX IF NOT EXISTS ux_health_param_weights_param_applicable
    ON health_param_weights (param_name, applicable_to);

-- HealthSnapshot
CREATE TABLE IF NOT EXISTS health_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    locomotive_id TEXT NOT NULL,
    score DOUBLE PRECISION NOT NULL,
    category TEXT NOT NULL,
    top_factors_json TEXT,
    calculated_at TIMESTAMPTZ NOT NULL
);

-- Index from @Table(indexes=...)
CREATE INDEX IF NOT EXISTS idx_snapshot_loco_time
    ON health_snapshots (locomotive_id, calculated_at DESC);
