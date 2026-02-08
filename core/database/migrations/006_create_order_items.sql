CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER,
    item_id INTEGER,
    item_name TEXT,
    quantity INTEGER,
    price NUMERIC,
    item_status TEXT,
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    FOREIGN KEY (item_id) REFERENCES menu(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
