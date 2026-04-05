INSERT INTO locomotives (id, code, model, type, status, manufactured_at)
VALUES (gen_random_uuid(), 'TE33A-0021', 'TE33A', 'DIESEL', 'ACTIVE', '2008-03-10')
ON CONFLICT (code) DO NOTHING;
