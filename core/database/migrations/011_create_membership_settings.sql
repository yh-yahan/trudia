CREATE TABLE membership_settings (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    enabled INTEGER DEFAULT 0,
    earn_points INTEGER, -- x points
    earn_spend INTEGER, -- y spend (in cents)
    redeem_points INTEGER, -- x points
    redeem_value INTEGER, -- value (in cents)
    earn_on TEXT, -- subtotal/total
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
