CREATE TABLE tax_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    rate INTEGER, -- scaled integer, with the scale being 1,000,000
    scope TEXT, -- item/order
    apply_to TEXT, -- all/taxable_only
    priority INTEGER, 
    active INTEGER, 
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
