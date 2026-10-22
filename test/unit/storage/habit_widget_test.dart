// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/habit_widget/habit_widget_api.g.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_widget.dart';
import 'package:mhabit/storage/habit_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const home = MethodChannel('home_widget');
  const display = BasicMessageChannel<Object?>(
    'dev.flutter.pigeon.mhabit.HabitWidgetDisplayHostApi.published',
    HabitWidgetDisplayHostApi.pigeonChannelCodec,
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String> events;
  late List<String> savedKeys;
  late String? rejected;
  String? storedSnapshot;
  final snapshot = HabitWidgetSnapshot(
    generatedAt: DateTime.utc(2026, 10, 17, 4),
    day: HabitDate(2026, 10, 17),
    nextDayAt: DateTime.utc(2026, 10, 17, 16),
    catalog: [],
  );

  setUp(() {
    events = [];
    savedKeys = [];
    rejected = null;
    storedSnapshot = null;
    PackageInfo.setMockInitialValues(
      appName: 'Table Habit',
      packageName: 'io.github.friesi23.mhabit.dev',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    messenger.setMockMethodCallHandler(home, (call) async {
      events.add(call.method);
      if (call.method == 'getWidgetData') return storedSnapshot;
      if (call.method == 'saveWidgetData') {
        final args = call.arguments as Map<Object?, Object?>;
        savedKeys.add(args['id']! as String);
        expect(jsonDecode(args['data']! as String), snapshot.toJson());
      }
      return call.method != rejected;
    });
    messenger.setMockDecodedMessageHandler(display, (_) async {
      events.add('nativePublished');
      return rejected == 'nativePublished'
          ? <Object?>['unavailable', 'Native display queue unavailable', null]
          : <Object?>[];
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(home, null);
    messenger.setMockDecodedMessageHandler(display, null);
  });

  test(
    'publication saves only snapshot and lets the native queue own reload',
    () async {
      await HomeWidgetPublisher().publish(snapshot);
      expect(events, ['setAppGroupId', 'saveWidgetData', 'nativePublished']);
      expect(savedKeys, [
        HomeWidgetPublisher.snapshotKey,
      ]); // foreground never writes hold metadata
    },
  );

  test(
    'rejected App Group selection never reads or saves shared data',
    () async {
      rejected = 'setAppGroupId';
      await expectLater(HomeWidgetPublisher().readStrings(), throwsStateError);
      await expectLater(
        HomeWidgetPublisher().publish(snapshot),
        throwsStateError,
      );
      expect(events, ['setAppGroupId', 'setAppGroupId']);
      expect(savedKeys, isEmpty);
    },
  );

  test('localized keys preserve their existing JSON identifiers', () async {
    storedSnapshot = jsonEncode({
      'strings': {
        for (final key in HabitWidgetStringKey.values) key.name: key.name,
        'futureNativeLabel': 'ignored',
      },
    });
    final strings = await HomeWidgetPublisher().readStrings();
    expect(strings, {
      for (final key in HabitWidgetStringKey.values) key: key.name,
    });
    final localized = HabitWidgetSnapshot(
      generatedAt: snapshot.generatedAt,
      day: snapshot.day,
      nextDayAt: snapshot.nextDayAt,
      catalog: [],
      strings: strings,
    );
    expect(localized.toJson()['strings'], {
      for (final key in HabitWidgetStringKey.values) key.name: key.name,
    });
  });

  test('malformed or unsupported stored strings fall back safely', () async {
    for (final raw in [
      null,
      '{invalid',
      'null',
      '[]',
      '{}',
      '{"strings":[]}',
      '{"strings":{"today":42,"locale":null,"futureKey":"text"}}',
    ]) {
      storedSnapshot = raw;
      expect(
        await HomeWidgetPublisher().readStrings(),
        isEmpty,
        reason: '$raw',
      );
    }
    storedSnapshot = '{"strings":{"today":"Today","undo":false}}';
    expect(await HomeWidgetPublisher().readStrings(), {
      HabitWidgetStringKey.today: 'Today',
    });
  });

  test(
    'failed save never reconciles against an unpublished directory',
    () async {
      rejected = 'saveWidgetData';
      await expectLater(
        HomeWidgetPublisher().publish(snapshot),
        throwsStateError,
      );
      expect(events, ['setAppGroupId', 'saveWidgetData']);
    },
  );

  test(
    'native enqueue failure reports publication failure after the saved snapshot',
    () async {
      rejected = 'nativePublished';
      await expectLater(
        HomeWidgetPublisher().publish(snapshot),
        throwsA(isA<PlatformException>()),
      );
      expect(events, ['setAppGroupId', 'saveWidgetData', 'nativePublished']);
    },
  );
}
