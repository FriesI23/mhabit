import 'package:pigeon/pigeon.dart';

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

class HabitWidgetRequest {
  HabitWidgetRequest({
    required this.operation,
    this.habitId,
    this.day,
    this.expectedRecord,
  });

  HabitWidgetOperation operation;
  String? habitId;
  String? day;
  String? expectedRecord;
}

@HostApi()
abstract class HabitWidgetHostApi {
  /// Sent only after the headless Dart action handler is installed.
  void ready();
}

@FlutterApi()
abstract class HabitWidgetBackgroundApi {
  @async
  HabitWidgetResult perform(HabitWidgetRequest request);
}

@FlutterApi()
abstract class HabitWidgetForegroundApi {
  /// Invalidates foreground caches after a completed background action.
  void changed();
}
