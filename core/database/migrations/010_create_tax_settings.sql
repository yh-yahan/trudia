CREATE TABLE tax_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    enabled INTEGER DEFAULT 0, 
    rate INTEGER DEFAULT 100, -- scaled integer (1% = 100)
    name TEXT, 
    registration_number TEXT DEFAULT '', 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
