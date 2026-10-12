ALTER TABLE menu ADD COLUMN updated_at TEXT NOT NULL DEFAULT '';
ALTER TABLE menu ADD COLUMN deleted_at TEXT DEFAULT NULL;

UPDATE menu SET updated_at = created_at WHERE updated_at = '';
