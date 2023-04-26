CREATE TABLE IF NOT EXISTS mh_records (
    id_ INTEGER PRIMARY KEY AUTOINCREMENT,
    parent_id INTEGER NOT NULL REFERENCES mh_habits(id_),
    record_date INTEGER NOT NULL,
    record_type INTEGER NOT NULL,
    record_value REAL NOT NULL DEFAULT 0,
    create_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    modify_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    uuid TEXT NOT NULL UNIQUE,
    parent_uuid TEXT NOT NULL REFERENCES mh_habits(uuid),
    reason TEXT NOT NULL DEFAULT ''
);
