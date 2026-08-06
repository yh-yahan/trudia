PRAGMA foreign_keys = OFF;

CREATE TABLE membership_transactions_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    membership_id INTEGER NOT NULL,
    order_session_id INTEGER, 
    type TEXT NOT NULL,
    points INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (membership_id) REFERENCES memberships(id) ON DELETE RESTRICT,
    FOREIGN KEY (order_session_id) REFERENCES order_sessions(id) ON DELETE RESTRICT
);

INSERT INTO membership_transactions_new (
    id, membership_id, order_session_id, type, points, created_at, updated_at
)
SELECT 
    id, membership_id, order_session_id, type, points, created_at, updated_at
FROM membership_transactions;

DROP TABLE membership_transactions;

ALTER TABLE membership_transactions_new RENAME TO membership_transactions;

PRAGMA foreign_keys = ON;
