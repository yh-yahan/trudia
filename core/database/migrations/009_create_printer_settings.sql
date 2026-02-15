CREATE TABLE printers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    printer_interface TEXT NOT NULL,
    connection_type TEXT,
    ip_address TEXT,
    port INTEGER,
    com_port TEXT,
    baud_rate INTEGER,
    parity TEXT,
    data_bits INTEGER,
    stop_bits INTEGER,
    flow_control TEXT,
    paper_width INTEGER,
    char_per_line INTEGER,
    cut_mode TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
