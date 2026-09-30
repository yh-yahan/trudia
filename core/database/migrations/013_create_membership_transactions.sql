CREATE TABLE membership_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    membership_id INTEGER NOT NULL,
    order_session_id INTEGER NOT NULL,
    type TEXT, -- earn/redeem
    points INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (membership_id) REFERENCES memberships(id)
        ON DELETE RESTRICT,
    FOREIGN KEY (order_session_id) REFERENCES order_sessions(id)
        ON DELETE RESTRICT
);
