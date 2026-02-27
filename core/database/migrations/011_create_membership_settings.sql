CREATE TABLE membership_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    enabled INTEGER DEFAULT 0,
    earn_rate INTEGER, -- points per RM 1
    min_spend INTEGER, -- scaled to cents
    earn_on TEXT, -- subtotal/total
    conversion INTEGER, -- x points = RM1
    redeem_min_point INTEGER, -- minimum points to redeem
    partial_redemption  INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
