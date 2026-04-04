-- Включаем генерацию UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Таблица локомотивов
CREATE TABLE IF NOT EXISTS locomotives (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL, -- Бортовой номер, например 'KZ8A-001'
    model VARCHAR(50) NOT NULL,       -- 'KZ8A' или 'TE33A'
    type VARCHAR(20) NOT NULL CHECK (type IN ('ELECTRIC', 'DIESEL')),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'MAINTENANCE', 'DECOMMISSIONED')),
    manufactured_at DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Справочник параметров телеметрии
CREATE TABLE IF NOT EXISTS parameter_definitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL, -- Уникальный код параметра: 'speed', 'coolant_temp'
    name VARCHAR(100) NOT NULL,       -- Человекочитаемое название
    unit VARCHAR(20),                 -- Единица измерения: 'km/h', '°C', 'MPa'
    min_val DOUBLE PRECISION,         -- Физический минимум датчика
    max_val DOUBLE PRECISION          -- Физический максимум датчика
);

-- 3. Конфигурация порогов для алертов (привязка к конкретному локомотиву)
CREATE TABLE IF NOT EXISTS threshold_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loco_id UUID NOT NULL REFERENCES locomotives(id) ON DELETE CASCADE,
    param_id UUID NOT NULL REFERENCES parameter_definitions(id) ON DELETE CASCADE,
    warning_low DOUBLE PRECISION,
    warning_high DOUBLE PRECISION,
    critical_low DOUBLE PRECISION,
    critical_high DOUBLE PRECISION,
    UNIQUE(loco_id, param_id) -- Один параметр для одного локомотива настраивается один раз
);

-- 4. Веса для расчета Индекса Здоровья (зависят от типа локомотива)
CREATE TABLE IF NOT EXISTS health_weights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loco_type VARCHAR(20) NOT NULL CHECK (loco_type IN ('ELECTRIC', 'DIESEL')),
    param_id UUID NOT NULL REFERENCES parameter_definitions(id) ON DELETE CASCADE,
    weight DOUBLE PRECISION NOT NULL CHECK (weight > 0 AND weight <= 1), -- Вес параметра от 0 до 1
    UNIQUE(loco_type, param_id)
);

-- 5. Журнал инцидентов (Алерты)
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    loco_id UUID NOT NULL REFERENCES locomotives(id) ON DELETE CASCADE,
    param_id UUID NOT NULL REFERENCES parameter_definitions(id),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('WARNING', 'CRITICAL')),
    value DOUBLE PRECISION NOT NULL,  -- Значение, при котором сработал алерт
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE -- NULL означает, что алерт еще активен
);

-- Индексы для оптимизации запросов
CREATE INDEX IF NOT EXISTS idx_alerts_loco_id ON alerts(loco_id);
CREATE INDEX IF NOT EXISTS idx_alerts_created_at ON alerts(created_at);
CREATE INDEX IF NOT EXISTS idx_alerts_unresolved ON alerts(loco_id) WHERE resolved_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_thresholds_loco_param ON threshold_configs(loco_id, param_id);
