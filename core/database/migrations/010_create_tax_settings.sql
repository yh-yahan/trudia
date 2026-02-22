CREATE TABLE tax_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    enabled INTEGER,
    registration_number TEXT,
    price_mode TEXT, -- exclusive/inclusive
    rounding_strategy TEXT, -- per_line/per_order
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
