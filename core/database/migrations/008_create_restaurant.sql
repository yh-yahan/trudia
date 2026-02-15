CREATE TABLE IF NOT EXISTS restaurant ( 
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    name TEXT, 
    address TEXT, 
    phone_number TEXT, 
    email TEXT, 
    website TEXT, 
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);