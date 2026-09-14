CREATE TABLE IF NOT EXISTS order_item_modifiers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_item_id INTEGER NOT NULL,
    modifier_id INTEGER,
    group_id INTEGER,
    group_name TEXT NOT NULL,
    name TEXT NOT NULL,
    price_delta INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_item_id) REFERENCES order_items(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (modifier_id) REFERENCES modifiers(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    FOREIGN KEY (group_id) REFERENCES modifier_groups(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
