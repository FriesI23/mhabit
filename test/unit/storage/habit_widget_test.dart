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
      if (call.method == 'getWidgetData') {
        if (rejected == 'getWidgetData') {
          throw PlatformException(code: 'unavailable');
        }
        return storedSnapshot;
      }
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
      await expectLater(HomeWidgetPublisher().readLocale(), throwsStateError);
      await expectLater(
        HomeWidgetPublisher().publish(snapshot),
        throwsStateError,
      );
      expect(events, ['setAppGroupId', 'setAppGroupId']);
      expect(savedKeys, isEmpty);
    },
  );

  test(
    'root locale takes priority and legacy locale is inherited read-only',
    () async {
      for (final (data, expectedLocale) in [
        (
          {
            'locale': 'ar',
            'strings': {'locale': 'zh_Hant'},
          },
          'ar',
        ),
        (
          {
            'locale': null,
            'strings': {'locale': 'zh_Hant'},
          },
          'zh_Hant',
        ),
        (
          {
            'strings': {'locale': 'ru', 'today': 'Сегодня'},
          },
          'ru',
        ),
        ({'locale': 'en_US'}, 'en_US'),
        ({'locale': ''}, ''),
      ]) {
        storedSnapshot = jsonEncode(data);
        final original = storedSnapshot;
        expect(await HomeWidgetPublisher().readLocale(), expectedLocale);
        expect(storedSnapshot, original);
      }
      expect(events, everyElement(isIn(['setAppGroupId', 'getWidgetData'])));
      expect(savedKeys, isEmpty);
    },
  );

  test(
    'malformed or non-string stored locales return null without writes',
    () async {
      for (final raw in [
        null,
        '{invalid',
        'null',
        '[]',
        '{}',
        '{"locale":42}',
        '{"locale":null}',
        '{"strings":[]}',
        '{"strings":{"locale":false,"today":"ignored"}}',
        '{"strings":{"locale":null}}',
      ]) {
        storedSnapshot = raw;
        expect(
          await HomeWidgetPublisher().readLocale(),
          isNull,
          reason: '$raw',
        );
        expect(storedSnapshot, raw);
      }
      expect(savedKeys, isEmpty);
    },
  );

  test(
    'shared locale read errors propagate without replacing stored data',
    () async {
      storedSnapshot = '{"locale":"ar"}';
      rejected = 'getWidgetData';
      await expectLater(
        HomeWidgetPublisher().readLocale(),
        throwsA(isA<PlatformException>()),
      );
      expect(storedSnapshot, '{"locale":"ar"}');
      expect(events, ['setAppGroupId', 'getWidgetData']);
      expect(savedKeys, isEmpty);
    },
  );

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
