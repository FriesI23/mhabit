CREATE INDEX IF NOT EXISTS habit_status ON mh_habits (status);
CREATE UNIQUE INDEX IF NOT EXISTS habit_uuid ON mh_habits (uuid);
CREATE INDEX IF NOT EXISTS habit_start_date ON mh_habits (start_date);
CREATE INDEX IF NOT EXISTS record_status ON mh_records (parent_id);
CREATE INDEX IF NOT EXISTS record_status ON mh_records (record_date);
CREATE INDEX IF NOT EXISTS record_status ON mh_records (parent_id, record_date);
CREATE UNIQUE INDEX IF NOT EXISTS record_uuid ON mh_records (uuid);