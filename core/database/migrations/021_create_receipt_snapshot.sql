CREATE TABLE IF NOT EXISTS receipt_snapshot (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_session_id INTEGER NOT NULL,

    store_name TEXT,
    address TEXT,
    phone TEXT,
    email TEXT,
    website TEXT,

    tax_name TEXT,
    tax_rate REAL,
    tax_registration_number TEXT,

    order_type TEXT,
    table_name TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_session_id) REFERENCES order_sessions(id)
        ON DELETE CASCADE
);
