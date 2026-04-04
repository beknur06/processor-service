
-- Таблица для AlertThreshold
CREATE TABLE alert_thresholds (
    id UUID PRIMARY KEY,
    param_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    warning_high DOUBLE PRECISION,
    warning_low DOUBLE PRECISION,
    critical_high DOUBLE PRECISION,
    critical_low DOUBLE PRECISION,
    warning_recommendation VARCHAR(500),
    critical_recommendation VARCHAR(500),
    applicable_to VARCHAR(255) NOT NULL DEFAULT 'BOTH',
    enabled BOOLEAN NOT NULL DEFAULT TRUE
);

-- Таблица для Alert
CREATE TABLE alerts (
    id UUID PRIMARY KEY,
    locomotive_id VARCHAR(255) NOT NULL,
    severity VARCHAR(255) NOT NULL,
    param_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    param_value DOUBLE PRECISION NOT NULL,
    threshold_value DOUBLE PRECISION NOT NULL,
    message VARCHAR(500) NOT NULL,
    recommendation VARCHAR(500),
    status VARCHAR(255) NOT NULL,
    triggered_at TIMESTAMP WITH TIME ZONE NOT NULL,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE
);

-- Индексы, указанные в аннотации @Table(indexes = ...) сущности Alert
CREATE INDEX idx_alert_loco_status ON alerts (locomotive_id, status);
CREATE INDEX idx_alert_triggered ON alerts (triggered_at DESC);