CREATE TABLE IF NOT EXISTS inventory_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL, 
    base_unit TEXT NOT NULL, 
    quantity INTEGER NOT NULL DEFAULT 0,
    low_quantity INTEGER, -- in base_unit
    deleted_at TEXT DEFAULT NULL,
    sale_paused_at TEXT DEFAULT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stock_movements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    inventory_item_id INTEGER NOT NULL REFERENCES inventory_items(id),
    quantity INTEGER NOT NULL, -- signed integer
    reason TEXT NOT NULL, -- receive, sale, waste, adjust
    idempotency_key TEXT NOT NULL UNIQUE,
    reference_id INTEGER,
    note TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
