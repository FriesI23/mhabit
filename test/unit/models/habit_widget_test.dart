// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_widget.dart';

void main() {
  test('record actions have stable URI hosts and round-trip every source', () {
    const hosts = {
      HabitWidgetAction.complete: 'complete',
      HabitWidgetAction.undo: 'undo',
      HabitWidgetAction.markIncomplete: 'mark-incomplete',
    };
    for (final action in HabitWidgetAction.values) {
      for (final source in HabitWidgetSource.values) {
        final command = HabitWidgetCommand(
          action: action,
          source: source,
          habitId: 'habit /?&=',
          day: HabitDate(2026, 10, 23),
          expectedRecord: 'version /?&=',
        );
        final uri = command.toUri();
        expect(uri.host, hosts[action]);
        final decoded = HabitWidgetCommand.tryParse(uri)!;
        expect(decoded.action, action);
        expect(decoded.source, source);
        expect(decoded.habitId, command.habitId);
        expect(decoded.day, command.day);
        expect(decoded.expectedRecord, command.expectedRecord);
        expect(decoded.toUri(), uri);
      }
    }
    for (final host in [
      'markIncomplete',
      'markincomplete',
      'next',
      'refresh',
    ]) {
      expect(HabitWidgetAction.fromUriHost(host), isNull, reason: host);
    }
  });

  test('v2 snapshots publish only the nullable root locale', () {
    for (final locale in [null, 'en', 'zh_Hant', 'ar']) {
      final snapshot = HabitWidgetSnapshot(
        generatedAt: DateTime.utc(2026, 10, 22, 4),
        day: HabitDate(2026, 10, 22),
        nextDayAt: DateTime.utc(2026, 10, 22, 16),
        catalog: [],
        locale: locale,
      );
      final json = snapshot.toJson();
      expect(json['version'], 2);
      expect(snapshot.locale, locale);
      expect(json, containsPair('locale', locale));
      expect(json, isNot(contains('strings')));
      expect(json['catalog'], isEmpty);
      expect(json['activeCount'], 0);
      expect(json['completedCount'], 0);
    }
  });

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
