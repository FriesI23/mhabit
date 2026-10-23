# Shared iOS widget snapshot contract

Dart's service test produces `snapshot-v2.json`; `HabitWidgetTests` decodes the
same fixture as a resource. Only the current v2 format is supported. IDs are stable
UUIDs and array order is authoritative
(`sortPosition`, then UUID). The fixture's civil day is 2026-10-17.

Version 2 requires the envelope (`version`, UTC `generatedAt`, local `day`, UTC
`nextDayAt`), complete `catalog`, `activeCount`, and `completedCount`. The directory
includes every non-deleted habit, including archived, future and unknown states.
Counters cover active, started habits only, independently of visible slots.

Each catalog item requires identity/name/ARGB color, Dart-calculated `completed`,
`progress`, `canComplete`, `canUndo`, opaque `expectedRecord`, seven ordered daily
progress cells, `state` (active/archived/unknown), local `startDate`, `started`,
`skipped`, and stable `automaticEligible` (active, started, not skipped).
`canMarkIncomplete` and `automaticPending` are required projection fields.
Ordinary effective `done/0` records are
processed: neither completion action is available and `automaticPending=false`.
Missing/deleted records and positive partial values remain pending; negative zero
uses the existing goal calculation. Native code does not infer this from progress.
Automatic candidates require stable eligibility and either pending status or a
matching shared hold, independently of the actual achieved counter.
Archived capability flags describe fixed-slot actions; they do not grant automatic
write permission. Dart remains authoritative inside the write transaction.

`recordState` is a required display-only field: `unknown`, `unrecorded`,
`notAchieved`, `achieved`, or `skipped`. Dart publishes it for every catalog item.
Future or unknown-lifecycle items use `unknown`; deleted records are `unrecorded`.
An effective `done/0` is evaluated by the existing domain goal calculation:
normal zero is not achieved, while negative zero may be achieved (for example
0–0 and 0–3 goals). Native code never infers record presence from progress.
An explicit `notAchieved` with `automaticPending=false` displays “Incomplete”.

`locale` is the optional application language used by native resource lookup.
Missing native translations fall back through English resources to hardcoded
English defaults.
A stale civil day disables actions; it is not evidence of deletion or completion.
Malformed data, unsupported versions, missing v2 fields, duplicate IDs and
inconsistent counters fail closed and cannot confirm that a fixed habit was deleted.

Mutation responses carry an explicit `outcome` and `snapshotPublished`.
Only `applied` carries `recordVersion` (read after record/sync updates in the same
SQLite transaction) and UTC ISO-8601 `committedAt` (sampled after commit succeeds).
Publication failure leaves the outcome applied. Mutations require an explicit
automatic/fixed source on both the typed bridge and internal URIs. Fixed allows
started archived habits; automatic does not.

Publication saves the snapshot, then acknowledges enqueueing on the native display
queue. Runner requests reloads after processing the current action's response and
matching hold; Dart never reloads ahead of that state. `snapshotPublished` means
the snapshot was saved and its notification accepted, not that WidgetKit already
rendered every component. A timeline entry captures hold values with its snapshot.

Native holds use atomic `habit_widget_holds.json` file replacement in the same
App Group. The v2 envelope requires a `completed` or `incomplete` result per hold.
Reading never writes. Only an applied automatic mutation creates a hold; its day,
eligibility, result projection and record version must still match. Next removes
only the matching identity without changing records. Undo tombstones the record,
including after overwriting a partial value with zero. Each reload follows the
completed file write. Habit records and sync stay in Dart.

Typed operations use `complete=0`, `undo=1`, `refresh=2`, and `markIncomplete=3`;
internal URIs explicitly use `mark-incomplete`. Development-only snapshot formats,
hold formats and preference storage are not migrated. The widget is unreleased;
format changes replace the contract directly. Swift snapshot and hold models
declare their supported wire versions with separate raw-value enums. Unknown
values fail decoding rather than passing an open-ended numeric range. If another
format is supported later, dispatch at the decoding boundary into the appropriate
wire type and normalize it into the runtime model.
