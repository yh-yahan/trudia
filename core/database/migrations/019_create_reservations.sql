CREATE TABLE IF NOT EXISTS reservations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT,
    customer_phone TEXT,
    pax INTEGER,
    table_id INTEGER REFERENCES tables(id) ON DELETE CASCADE,
    reservation_datetime DATETIME,
    duration_minutes INTEGER,
    status TEXT, 
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
