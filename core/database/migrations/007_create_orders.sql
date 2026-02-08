CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_session_id INTEGER NOT NULL,
    display_number INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TEXT NULL,
        FOREIGN KEY (order_session_id) REFERENCES order_sessions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
