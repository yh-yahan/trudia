CREATE TABLE IF NOT EXISTS order_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    display_number INTEGER NOT NULL,
    receipt_number TEXT NULL,
    table_id INTEGER NULL,
    order_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open',
    points_earned INTEGER DEFAULT 0,
    points_redeemed INTEGER DEFAULT 0,
    subtotal NUMERIC NOT NULL DEFAULT 0,
    tax NUMERIC NOT NULL DEFAULT 0,
    discount NUMERIC DEFAULT 0,
    total NUMERIC NOT NULL DEFAULT 0,
    opened_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TEXT NULL,
    FOREIGN KEY (table_id) REFERENCES tables(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
