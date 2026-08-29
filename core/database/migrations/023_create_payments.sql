CREATE TABLE IF NOT EXISTS payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_session_id INTEGER NOT NULL,
    method TEXT NOT NULL,
    amount INTEGER NOT NULL,
    type TEXT NOT NULL DEFAULT 'sale', -- sale, void, refund
    reverses_payment_id INTEGER, -- null for sales
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_session_id)
        REFERENCES order_sessions(id)
        ON DELETE CASCADE
);
