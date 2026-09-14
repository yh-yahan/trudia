CREATE TABLE IF NOT EXISTS modifier_groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL, 
    selection_type TEXT NOT NULL, -- single/multi
    min_select INTEGER NOT NULL DEFAULT 0,
    max_select INTEGER, -- NULL = no max
    is_required INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS modifiers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id INTEGER NOT NULL,
    name TEXT NOT NULL, 
    price_delta INTEGER NOT NULL DEFAULT 0, -- add to item price, can be 0 or negative
    is_default INTEGER NOT NULL DEFAULT 0,
    is_available INTEGER NOT NULL DEFAULT 1,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES modifier_groups(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS menu_modifier_groups (
    menu_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (menu_id, group_id),
    FOREIGN KEY (menu_id) REFERENCES menu(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (group_id) REFERENCES modifier_groups(id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
