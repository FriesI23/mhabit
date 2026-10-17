// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/habit_widget_entry.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_widget.dart';
import 'package:mhabit/providers/workflow/app_event.dart';
import 'package:mhabit/providers/workflow/habit_widget.dart';
import 'package:mhabit/providers/workflow/habits_manager.dart';
import 'package:mhabit/storage/db/db_helper.dart';
import 'package:mhabit/storage/habit_widget.dart';
import 'package:mhabit/widgets/widgets.dart' show DateChangeNotifier;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

const _codec = StandardMethodCodec();
const _backgroundChannel = MethodChannel(
  HabitWidgetBackgroundChannel.channelName,
);

Future<Object?> _sendNativeCall(String channel, MethodCall call) async {
  final result = Completer<Object?>();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(channel, _codec.encodeMethodCall(call), (data) {
        result.complete(data == null ? null : _codec.decodeEnvelope(data));
      });
  return result.future;
}

final class _EmptyDatabase implements Database, Transaction {
  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) => action(this);

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async => [];

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _EmptyDBHelper implements DBHelper {
  @override
  final Database db = _EmptyDatabase();

  @override
  Future<void> init({bool reinit = false}) async {}

  @override
  void dispose() {}
}

final class _SnapshotPublisher implements HabitWidgetPublisher {
  final snapshots = <HabitWidgetSnapshot>[];

  @override
  Future<Map<String, String>> readStrings() async => {};

  @override
  Future<void> publish(HabitWidgetSnapshot snapshot) async {
    snapshots.add(snapshot);
  }
}

class _BridgeHost extends StatefulWidget {
  const _BridgeHost();

  @override
  State<_BridgeHost> createState() => _BridgeHostState();
}

class _BridgeHostState extends State<_BridgeHost> {
  final bridge = HabitWidgetPostInitBridge();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bridge.sync(context, l10n: L10n.of(context));
  }

  @override
  void dispose() {
    bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_backgroundChannel, null);
  });

  test('native ready means the action handler is already installed', () async {
    final calls = <Uri>[];
    final bridge = HabitWidgetBackgroundChannel((uri) async {
      calls.add(uri);
      return true;
    });
    addTearDown(bridge.dispose);
    Object? firstResult;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_backgroundChannel, (call) async {
          expect(call.method, 'ready');
          firstResult = await _sendNativeCall(
            _backgroundChannel.name,
            const MethodCall('perform', 'tablehabit-widget://complete'),
          );
          return null;
        });

    await bridge.start();

    expect(firstResult, isTrue);
    expect(calls.single.host, 'complete');
  });

  test('native success waits for the persistence action to finish', () async {
    final committed = Completer<bool>();
    final bridge = HabitWidgetBackgroundChannel((_) => committed.future);
    addTearDown(bridge.dispose);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_backgroundChannel, (_) async => null);
    await bridge.start();
    var acknowledged = false;
    final result =
        _sendNativeCall(
          _backgroundChannel.name,
          const MethodCall('perform', 'tablehabit-widget://complete'),
        ).then((value) {
          acknowledged = true;
          return value;
        });
    await Future<void>.delayed(Duration.zero);
    expect(acknowledged, isFalse);

    committed.complete(true);
    expect(await result, isTrue);
  });

  test(
    'invalid messages and failed actions never acknowledge success',
    () async {
      var attempts = 0;
      final bridge = HabitWidgetBackgroundChannel((_) async {
        attempts++;
        throw StateError('Database unavailable');
      });
      addTearDown(bridge.dispose);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_backgroundChannel, (_) async => null);
      await bridge.start();

      for (final call in [
        const MethodCall('other', 'tablehabit-widget://complete'),
        const MethodCall('perform', {'uri': 'tablehabit-widget://complete'}),
        const MethodCall('perform', 'http://[invalid'),
      ]) {
        expect(await _sendNativeCall(_backgroundChannel.name, call), isFalse);
      }
      expect(attempts, 0);
      expect(
        await _sendNativeCall(
          _backgroundChannel.name,
          const MethodCall('perform', 'tablehabit-widget://complete'),
        ),
        isFalse,
      );
      expect(attempts, 1);
    },
  );

  testWidgets('foreground refreshes snapshots and invalidates UI caches', (
    tester,
  ) async {
    final publisher = _SnapshotPublisher();
    final service = HabitWidgetService(
      database: _EmptyDBHelper(),
      habitsManager: HabitsManager(),
      publisher: publisher,
    );
    final events = AppEventBus();
    final dates = DateChangeNotifier();
    final reloads = <ReloadDataEvent>[];
    final subscription = events.on<ReloadDataEvent>().listen(reloads.add);
    addTearDown(subscription.cancel);
    addTearDown(events.dispose);
    addTearDown(dates.dispose);

    Widget app(Locale locale) => MultiProvider(
      providers: [
        Provider<HabitWidgetService>.value(value: service),
        ChangeNotifierProvider<AppEventBus>.value(value: events),
        ChangeNotifierProvider<DateChangeNotifier>.value(value: dates),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: const _BridgeHost(),
      ),
    );

    await tester.pumpWidget(app(const Locale('en')));
    await tester.pumpAndSettle();
    expect(publisher.snapshots.last.strings['today'], 'Today');
    var published = publisher.snapshots.length;

    events.push(const ReloadDataEvent(msg: 'sync/import/clear'));
    await tester.pumpAndSettle();
    expect(publisher.snapshots.length, greaterThan(published));
    published = publisher.snapshots.length;

    await _sendNativeCall(
      'table_habit/widget_foreground',
      const MethodCall('changed'),
    );
    await tester.pumpAndSettle();
    expect(reloads.last.msg, 'habit_widget.changed');
    expect(publisher.snapshots.length, greaterThan(published));
    final reloadCount = reloads.length;

    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      // ignore: invalid_use_of_protected_member
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pump();
    }
    expect(reloads.length, reloadCount + 1);
    published = publisher.snapshots.length;

    dates.dateTime = HabitDate.now().addDays(1);
    dates.tzName = 'Europe/Moscow';
    await tester.pumpAndSettle();
    expect(publisher.snapshots.length, greaterThan(published));

    await tester.pumpWidget(app(const Locale('ru')));
    await tester.pumpAndSettle();
    expect(
      publisher.snapshots.last.strings['today'],
      lookupL10n(const Locale('ru')).habitDisplay_tab_today_label,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    published = publisher.snapshots.length;
    events.push(const ReloadDataEvent());
    dates.dateTime = HabitDate.now().addDays(2);
    await tester.pumpAndSettle();
    expect(publisher.snapshots.length, published);
    expect(tester.takeException(), isNull);
  });
}
