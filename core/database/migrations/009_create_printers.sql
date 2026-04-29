CREATE TABLE IF NOT EXISTS printers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    system_name TEXT NOT NULL UNIQUE, -- windows printer name
    role TEXT NOT NULL, -- receipt/kitchen/both
    paper_width INTEGER NOT NULL DEFAULT 58, -- 58/80
    cut_mode TEXT NOT NULL DEFAULT "none", -- full/partial/none
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
