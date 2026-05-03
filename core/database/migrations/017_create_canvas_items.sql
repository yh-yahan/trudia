CREATE TABLE IF NOT EXISTS canvas_items (
    id TEXT PRIMARY KEY AUTOINCREMENT,
    floor_id TEXT NOT NULL REFERENCES floors(id) ON DELETE CASCADE,
    
    type TEXT NOT NULL, -- table/wall/room/door/text
    label TEXT, 
    capacity INTEGER, -- only for tables
    
    x REAL NOT NULL,
    y REAL NOT NULL,
    width REAL NOT NULL,
    height REAL NOT NULL,
    rotation REAL DEFAULT 0,
    
    color TEXT, -- hex
    border_color TEXT,
    border_width REAL DEFAULT 2,
    opacity REAL DEFAULT 1.0,
    z_order INTEGER DEFAULT 0,
    
    metadata TEXT, -- json string
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
