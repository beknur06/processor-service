-- 1. Таблица локомотивов
CREATE TABLE IF NOT EXISTS locomotives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL, -- Бортовой номер, например 'KZ8A-001'
    model VARCHAR(50) NOT NULL,       -- 'KZ8A' или 'TE33A'
    type VARCHAR(20) NOT NULL CHECK (type IN ('ELECTRIC', 'DIESEL')),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'MAINTENANCE', 'DECOMMISSIONED')),
    manufactured_at DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Справочник параметров телеметрии
CREATE TABLE IF NOT EXISTS parameter_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL, -- Уникальный код параметра: 'speed', 'coolant_temp'
    name VARCHAR(100) NOT NULL,       -- Человекочитаемое название
    unit VARCHAR(50),                 -- Единица измерения
    min_val DOUBLE PRECISION,         -- Физический минимум датчика
    max_val DOUBLE PRECISION          -- Физический максимум датчика
);