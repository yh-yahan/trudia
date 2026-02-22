CREATE TABLE order_tax_lines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_session_id INTEGER,
    tax_rule_id INTEGER,
    tax_name_snapshot TEXT,
    rate_snapshot INTEGER, -- scaled integer, with the scale being 1,000,000
    amount INTEGER, -- stored as the smallest currency unit
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_session_id) REFERENCES order_sessions(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (tax_rule_id) REFERENCES tax_rules(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
