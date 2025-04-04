CREATE TABLE IF NOT EXISTS mh_sync (
    id_ INTEGER PRIMARY KEY AUTOINCREMENT,
    create_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    modify_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    habit_uuid TEXT UNIQUE REFERENCES mh_habits(uuid),
    record_uuid TEXT UNIQUE REFERENCES mh_records(uuid),
    dirty INTEGER NOT NULL DEFAULT 1,
    dirty_total INTEGER,
    last_config_uuid TEXT,
    last_session_uuid TEXT,
    last_mark TEXT,
    last_mark_2 TEXT,
    CHECK (
        (habit_uuid IS NOT NULL) + (record_uuid IS NOT NULL) <= 1
    )
);