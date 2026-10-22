# Shared iOS widget snapshot contract

Dart's service test produces `snapshot-v2.json`; `HabitWidgetTests` decodes both
fixtures as resources. IDs are stable UUIDs and array order is authoritative
(`sortPosition`, then UUID). The fixture's civil day is 2026-10-17.

Version 2 requires the envelope (`version`, UTC `generatedAt`, local `day`, UTC
`nextDayAt`), complete `catalog`, `activeCount`, and `completedCount`. The directory
includes every non-deleted habit, including archived, future and unknown states.
Counters cover active, started habits only, independently of visible slots.

Each catalog item requires identity/name/ARGB color, Dart-calculated `completed`,
`progress`, `canComplete`, `canUndo`, opaque `expectedRecord`, seven ordered daily
progress cells, `state` (active/archived/unknown), local `startDate`, `started`,
`skipped`, and stable `automaticEligible` (active, started, not skipped).
Completion is separate from stable eligibility: a completed automatic item can
remain visible only when native shared hold metadata matches its record version.
Archived capability flags describe fixed-slot actions; they do not grant automatic
write permission. Dart remains authoritative inside the write transaction.

`strings` is an optional application-language dictionary with native fallbacks.
A stale civil day disables actions; it is not evidence of deletion or completion.
Malformed data, unsupported versions, missing v2 fields, duplicate IDs and
inconsistent counters fail closed and cannot confirm that a fixed habit was deleted.

Version 1 uses `habits` and lacks directory/state metadata. Swift derives legacy
counts and active/started defaults for those items, marks the directory incomplete,
and never infers deletion from a missing UUID. The formal configured view uses
the unified catalog; the transitional static view and its public projection have
been removed. Global counts retain the active + started business definition.

Mutation responses carry an explicit `outcome` and `snapshotPublished`.
Only `applied` carries `recordVersion` (read after record/sync updates in the same
SQLite transaction) and UTC ISO-8601 `committedAt` (sampled after commit succeeds).
Publication failure leaves the outcome applied. Mutations require an explicit
automatic/fixed source on the typed bridge; legacy three-field URIs degrade to
automatic permission. Fixed allows started archived habits; automatic does not.

Publication saves the snapshot, then acknowledges enqueueing on the native display
queue. Runner requests reloads after processing the current action's response and
matching hold; Dart never reloads ahead of that state. `snapshotPublished` means
the snapshot was saved and its notification accepted, not that WidgetKit already
rendered every component. A timeline entry captures hold values with its snapshot.

Native holds use atomic `habit_widget_holds_v1.json` file replacement in the same
App Group. Each reload follows the completed file write. Legacy development
preference JSON is a fallback only while no file exists; an empty or invalid file
never revives a previous preference value. Habit records and sync stay in Dart.
