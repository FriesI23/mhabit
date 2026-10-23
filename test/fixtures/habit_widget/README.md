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
`canMarkIncomplete` and `automaticPending` are optional additive v2 fields, defaulting
to `false` and `!completed` when absent. Ordinary effective `done/0` records are
processed: neither completion action is available and `automaticPending=false`.
Missing/deleted records and positive partial values remain pending; negative zero
uses the existing goal calculation. Native code does not infer this from progress.
Automatic candidates require stable eligibility and either pending status or a
matching shared hold, independently of the actual achieved counter.
Archived capability flags describe fixed-slot actions; they do not grant automatic
write permission. Dart remains authoritative inside the write transaction.

`recordState` is an optional display-only field: `unknown`, `unrecorded`,
`notAchieved`, `achieved`, or `skipped`. Dart publishes it for every catalog item.
Future or unknown-lifecycle items use `unknown`; deleted records are `unrecorded`.
An effective `done/0` is evaluated by the existing domain goal calculation:
normal zero is not achieved, while negative zero may be achieved (for example
0–0 and 0–3 goals). Native code never infers record presence from progress.
Older snapshots without this field decode as `unknown` and keep legacy display,
capabilities, candidate selection, counters and holds. An explicit `notAchieved`
with `automaticPending=false` displays “Incomplete”; legacy missing fields cannot
establish that a zero value was recorded.

`locale` is the optional application language used by native resource lookup.
Legacy `strings.locale` is a fallback when root `locale` is absent; other legacy
string values no longer supply widget text. Missing native translations fall
back through English resources to hardcoded English defaults.
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
App Group. The v2 envelope stores a `completed` or `incomplete` result. A v1 hold
reads as completed with its original identity; reading never writes a migration.
The next actual change saves v2. Only an applied automatic mutation creates a
hold; its day, eligibility, result projection and record version must still match.
Next removes only the matching identity without changing records. Undo tombstones
the record, including after overwriting a partial value with zero.
Typed operations keep `complete=0`, `undo=1`, `refresh=2`, and append
`markIncomplete=3`; internal URIs explicitly use `mark-incomplete`.
Each reload follows the completed file write. Legacy development
preference JSON is a fallback only while no file exists; an empty or invalid file
never revives a previous preference value. Habit records and sync stay in Dart.
