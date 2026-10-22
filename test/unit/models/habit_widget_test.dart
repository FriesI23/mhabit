// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_widget.dart';

void main() {
  test('non-applied responses never carry committed record metadata', () {
    for (final outcome in HabitWidgetActionResult.values) {
      if (outcome == HabitWidgetActionResult.applied) continue;
      for (final published in [false, true]) {
        final response = HabitWidgetActionResponse.result(
          outcome,
          snapshotPublished: published,
        );
        expect(response.outcome, outcome);
        expect(response.snapshotPublished, published);
        expect(response.recordVersion, isNull);
        expect(response.committedAt, isNull);
      }
    }
  });

  test('applied response requires the committed metadata constructor', () {
    expect(
      () => HabitWidgetActionResponse.result(HabitWidgetActionResult.applied),
      throwsArgumentError,
    );
  });

  test(
    'failed publication retains the applied version and UTC commit time',
    () {
      final committed = DateTime(2026, 10, 22, 12, 34, 56, 123, 456);
      final response = HabitWidgetActionResponse.applied(
        recordVersion: 'committed-version',
        committedAt: committed,
        snapshotPublished: false,
      );
      expect(response.outcome, HabitWidgetActionResult.applied);
      expect(response.recordVersion, 'committed-version');
      expect(response.committedAt!.isUtc, isTrue);
      expect(response.committedAt, committed.toUtc());
      expect(response.snapshotPublished, isFalse);
    },
  );
}
