CREATE UNIQUE INDEX IF NOT EXISTS idx_mh_sync_habit_uuid ON mh_sync (habit_uuid, record_uuid);
CREATE UNIQUE INDEX IF NOT EXISTS idx_mh_sync_record_uuid ON mh_sync (record_uuid);
CREATE INDEX IF NOT EXISTS idx_mh_sync_dirty ON mh_sync (dirty);