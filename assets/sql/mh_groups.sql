CREATE TABLE IF NOT EXISTS mh_groups (
    id_ INTEGER PRIMARY KEY AUTOINCREMENT,
    create_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    modify_t INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as int)),
    uuid TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    desc TEXT,
    icon INTEGER,
    color INTEGER,
    custom_color INTEGER,
    custom_color_tinted INTEGER,
    status INTEGER NOT NULL DEFAULT 1
);
