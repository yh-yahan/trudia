CREATE TABLE IF NOT EXISTS kitchen_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mode TEXT NOT NULL, -- none, kds, tickets, hybrid
    ticket_print_timing TEXT NOT NULL, -- order_created, manual
    require_ready_for_checkout INT NOT NULL,
    allow_edit_after_send INTEGER NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
