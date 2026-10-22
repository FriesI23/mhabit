import 'package:pigeon/pigeon.dart';

/// Stable keys for localized values in the shared snapshot JSON.
///
/// The enum names are wire identifiers and must remain compatible with stored
/// snapshots. Pigeon generates matching identifiers for the native bridge.
enum HabitWidgetStringKey {
  today,
  complete,
  undo,
  empty,
  allDone,
  completed,
  skipped,
  habits,
  locale,
}

/// Operations accepted by the background execution channel.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/entries/habit_widget/habit_widget_api.g.dart',
    swiftOut: 'ios/HabitWidget/App/HabitWidgetApi.g.swift',
    swiftOptions: SwiftOptions(errorClassName: 'HabitWidgetApiError'),
    dartPackageName: 'mhabit',
  ),
)
enum HabitWidgetOperation { complete, undo, refresh }

/// Transport outcomes; domain rules and persistence stay in the Dart workflow.
enum HabitWidgetResult { applied, unchanged, stale, invalid, failed }

/// Identifies how the displayed entity was selected.
enum HabitWidgetSelectionSource { automatic, fixed }

/// Transfers an execution outcome and any committed record identity.
class HabitWidgetResponse {
  /// Creates a response returned after the requested operation finishes.
  HabitWidgetResponse({
    required this.outcome,
    required this.snapshotPublished,
    this.recordVersion,
    this.committedAt,
  });

  /// The outcome of the requested operation.
  HabitWidgetResult outcome;

  /// Whether publishing the resulting snapshot succeeded.
  bool snapshotPublished;

  /// The committed version; present only for an applied operation.
  String? recordVersion;

  /// UTC ISO-8601 acknowledgement time, sampled after the commit succeeded.
  String? committedAt;
}

/// Carries a native operation and the displayed state used to validate it.
class HabitWidgetRequest {
  /// Creates a request for background execution.
  HabitWidgetRequest({
    required this.operation,
    this.source,
    this.habitId,
    this.day,
    this.expectedRecord,
  });

  /// The operation to execute.
  HabitWidgetOperation operation;

  /// The selection mode, required for record operations.
  HabitWidgetSelectionSource? source;

  /// The stable entity identifier, required for record operations.
  String? habitId;

  /// The displayed local calendar date in ISO-8601 date form.
  String? day;

  /// The displayed record version used for compare-and-set validation.
  String? expectedRecord;
}

/// Reports readiness from the background engine to its native owner.
@HostApi()
abstract class HabitWidgetHostApi {
  /// Sent only after the headless Dart action handler is installed.
  void ready();
}

/// Enqueues native display reconciliation; never waits behind its own action.
@HostApi()
abstract class HabitWidgetDisplayHostApi {
  /// Acknowledges enqueueing after a shared snapshot has been saved.
  void published();
}

/// Executes native requests on the background Dart engine.
@FlutterApi()
abstract class HabitWidgetBackgroundApi {
  /// Completes after persistence and the publication attempt finish.
  @async
  HabitWidgetResponse perform(HabitWidgetRequest request);
}

/// Notifies the foreground Dart engine that its cached state may be outdated.
@FlutterApi()
abstract class HabitWidgetForegroundApi {
  /// Invalidates foreground caches after a completed background action.
  void changed();
}
