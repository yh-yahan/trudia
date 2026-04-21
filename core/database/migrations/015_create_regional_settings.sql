CREATE TABLE IF NOT EXISTS regional_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    locale TEXT NOT NULL DEFAULT 'en_US',
    currency_code TEXT NOT NULL DEFAULT 'USD', -- ISO 4217
    timezone TEXT DEFAULT 'America/New_York',
    date_format TEXT NOT NULL DEFAULT 'yyyy-MM-dd',
    time_format TEXT NOT NULL DEFAULT 'HH:mm',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
