-- modifier_groups
ALTER TABLE modifier_groups ADD COLUMN updated_at TEXT NOT NULL DEFAULT '';
ALTER TABLE modifier_groups ADD COLUMN deleted_at TEXT DEFAULT NULL;

UPDATE modifier_groups SET updated_at = created_at WHERE updated_at = '';

-- modifiers
ALTER TABLE modifiers ADD COLUMN updated_at TEXT NOT NULL DEFAULT '';
ALTER TABLE modifiers ADD COLUMN deleted_at TEXT DEFAULT NULL;

UPDATE modifiers SET updated_at = created_at WHERE updated_at = '';

-- menu_modifier_groups
ALTER TABLE menu_modifier_groups ADD COLUMN created_at TEXT NOT NULL DEFAULT '';
ALTER TABLE menu_modifier_groups ADD COLUMN updated_at TEXT NOT NULL DEFAULT '';
ALTER TABLE menu_modifier_groups ADD COLUMN deleted_at TEXT DEFAULT NULL;

UPDATE menu_modifier_groups SET created_at = CURRENT_TIMESTAMP WHERE created_at = '';
UPDATE menu_modifier_groups SET updated_at = created_at WHERE updated_at = '';
