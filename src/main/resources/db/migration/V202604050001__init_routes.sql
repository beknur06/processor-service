-- Routes catalogue: real KTZ (Kazakhstan Railways) routes with GPS waypoints
-- Source: Kazakhstan Railways (Temir Zholy) timetable data, ~973 km / ~190 km

CREATE TABLE IF NOT EXISTS routes (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id   VARCHAR(50)  UNIQUE NOT NULL,   -- simulator key, e.g. "ASTANA-ALMATY"
    name       VARCHAR(100) NOT NULL,
    total_km   DOUBLE PRECISION NOT NULL,       -- real rail distance in km
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS route_waypoints (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id      UUID             NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
    sort_order    INT              NOT NULL,
    city_name     VARCHAR(100)     NOT NULL,
    km_from_start DOUBLE PRECISION NOT NULL,    -- cumulative km from route start
    lat           DOUBLE PRECISION NOT NULL,
    lon           DOUBLE PRECISION NOT NULL,
    CONSTRAINT uk_route_waypoints_route_order UNIQUE (route_id, sort_order)
);

-- ── Seed: real KTZ routes ──────────────────────────────────────────────────

INSERT INTO routes (route_id, name, total_km) VALUES
    ('ASTANA-ALMATY',    'Астана-1 — Алматы-2',  973.0),
    ('ASTANA-KARAGANDA', 'Астана-1 — Қарағанды', 190.0)
ON CONFLICT (route_id) DO NOTHING;

INSERT INTO route_waypoints (route_id, sort_order, city_name, km_from_start, lat, lon)
SELECT r.id, w.sort_order, w.city_name, w.km_from_start, w.lat, w.lon
FROM (VALUES
    -- ASTANA-ALMATY  (Астана → Қарағанды → Балқаш → Алматы)
    ('ASTANA-ALMATY',    1, 'Astana',     0.0,   51.1956, 71.4089),
    ('ASTANA-ALMATY',    2, 'Karagandy',  190.0, 49.7870, 73.0980),
    ('ASTANA-ALMATY',    3, 'Balkash',    420.0, 46.8500, 74.9900),
    ('ASTANA-ALMATY',    4, 'Almaty',     973.0, 43.2740, 76.9390),
    -- ASTANA-KARAGANDA  (direct line, ~190 km)
    ('ASTANA-KARAGANDA', 1, 'Astana',     0.0,   51.1956, 71.4089),
    ('ASTANA-KARAGANDA', 2, 'Karagandy',  190.0, 49.7870, 73.0980)
) AS w(route_key, sort_order, city_name, km_from_start, lat, lon)
JOIN routes r ON r.route_id = w.route_key
ON CONFLICT DO NOTHING;
