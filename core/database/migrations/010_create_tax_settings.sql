CREATE TABLE tax_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    enabled INTEGER DEFAULT 1, 
    rate INTEGER DEFAULT 10000000,          -- Scaled integer (10.000000% = 10000000)
    name TEXT DEFAULT 'Sales Tax', 
    registration_number TEXT DEFAULT '', 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
