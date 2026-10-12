ALTER TABLE categories ADD COLUMN updated_at TEXT NOT NULL DEFAULT '';
ALTER TABLE categories ADD COLUMN deleted_at TEXT DEFAULT NULL;

UPDATE categories SET updated_at = created_at WHERE updated_at = '';
