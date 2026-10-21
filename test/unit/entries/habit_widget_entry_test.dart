// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/habit_widget_api.g.dart';
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

const _backgroundChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.mhabit.HabitWidgetBackgroundApi.perform',
  HabitWidgetBackgroundApi.pigeonChannelCodec,
);
const _foregroundChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.mhabit.HabitWidgetForegroundApi.changed',
  HabitWidgetForegroundApi.pigeonChannelCodec,
);
const _hostChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.mhabit.HabitWidgetHostApi.ready',
  HabitWidgetHostApi.pigeonChannelCodec,
);

final class _HostApi extends HabitWidgetHostApi {
  @override
  Future<void> ready() async {}
}

Future<Object?> _sendNativeCall(
  BasicMessageChannel<Object?> channel,
  Object? message,
) async {
  final result = Completer<Object?>();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        channel.name,
        channel.codec.encodeMessage(message),
        (data) {
          result.complete(channel.codec.decodeMessage(data));
        },
      );
  return result.future;
}

Future<HabitWidgetResult> _perform(HabitWidgetRequest request) async {
  final reply =
      await _sendNativeCall(_backgroundChannel, [request]) as List<Object?>;
  expect(reply, hasLength(1));
  return reply.single! as HabitWidgetResult;
}

HabitWidgetRequest _completeRequest() => HabitWidgetRequest(
  operation: HabitWidgetOperation.complete,
  habitId: 'habit-id',
  day: '2026-10-17',
  expectedRecord: 'none',
);

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

  test('native ready means the action handler is already installed', () async {
    final calls = <Uri>[];
    HabitWidgetResult? firstResult;
    final bridge = HabitWidgetBackgroundChannel((uri) async {
      calls.add(uri);
      return HabitWidgetActionResult.applied;
    });
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockDecodedMessageHandler(_hostChannel, (message) async {
      expect(message, isNull);
      firstResult = await _perform(_completeRequest());
      return <Object?>[];
    });
    addTearDown(
      () => messenger.setMockDecodedMessageHandler(_hostChannel, null),
    );
    addTearDown(bridge.dispose);

    await bridge.start();

    expect(firstResult, HabitWidgetResult.applied);
    final command = HabitWidgetCommand.tryParse(calls.single)!;
    expect(command.action, HabitWidgetAction.complete);
    expect(command.habitId, 'habit-id');
    expect(command.day, HabitDate(2026, 10, 17));
    expect(command.expectedRecord, 'none');
  });

  test('native success waits for the persistence action to finish', () async {
    final committed = Completer<HabitWidgetActionResult>();
    final bridge = HabitWidgetBackgroundChannel(
      (_) => committed.future,
      hostApi: _HostApi(),
    );
    addTearDown(bridge.dispose);
    await bridge.start();
    var acknowledged = false;
    final result = _perform(_completeRequest()).then((value) {
      acknowledged = true;
      return value;
    });
    await Future<void>.delayed(Duration.zero);
    expect(acknowledged, isFalse);

    committed.complete(HabitWidgetActionResult.applied);
    expect(await result, HabitWidgetResult.applied);
  });

  test(
    'invalid requests and failed actions never acknowledge success',
    () async {
      var attempts = 0;
      final bridge = HabitWidgetBackgroundChannel((_) async {
        attempts++;
        throw StateError('Database unavailable');
      }, hostApi: _HostApi());
      addTearDown(bridge.dispose);
      await bridge.start();

      for (final request in [
        HabitWidgetRequest(operation: HabitWidgetOperation.complete),
        _completeRequest()..day = '2026-02-30',
        _completeRequest()..habitId = '',
        HabitWidgetRequest(
          operation: HabitWidgetOperation.refresh,
          habitId: 'unexpected',
        ),
      ]) {
        expect(await _perform(request), HabitWidgetResult.invalid);
      }
      expect(attempts, 0);
      expect(await _perform(_completeRequest()), HabitWidgetResult.failed);
      expect(attempts, 1);
    },
  );

  test(
    'typed replies preserve workflow outcomes and refresh commands',
    () async {
      var outcome = HabitWidgetActionResult.applied;
      final calls = <Uri>[];
      final bridge = HabitWidgetBackgroundChannel((uri) async {
        calls.add(uri);
        return outcome;
      }, hostApi: _HostApi());
      addTearDown(bridge.dispose);
      await bridge.start();

      for (final pair in [
        (HabitWidgetActionResult.applied, HabitWidgetResult.applied),
        (HabitWidgetActionResult.unchanged, HabitWidgetResult.unchanged),
        (HabitWidgetActionResult.stale, HabitWidgetResult.stale),
        (HabitWidgetActionResult.invalid, HabitWidgetResult.invalid),
      ]) {
        outcome = pair.$1;
        expect(
          await _perform(
            HabitWidgetRequest(operation: HabitWidgetOperation.refresh),
          ),
          pair.$2,
        );
      }
      expect(
        calls.every((uri) => uri.toString() == 'tablehabit-widget://refresh'),
        isTrue,
      );
      outcome = HabitWidgetActionResult.applied;
      await _perform(_completeRequest()..operation = HabitWidgetOperation.undo);
      expect(
        HabitWidgetCommand.tryParse(calls.last)!.action,
        HabitWidgetAction.undo,
      );

      bridge.dispose();
      expect(
        await _sendNativeCall(_backgroundChannel, [_completeRequest()]),
        isNull,
      );
    },
  );

  testWidgets('foreground refreshes snapshots and invalidates UI caches', (
    tester,
  ) async {
    final publisher = _SnapshotPublisher();
    final service = HabitWidgetService(
      database: _EmptyDBHelper(),
      habitsAccess: HabitsManager(),
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

    await _sendNativeCall(_foregroundChannel, null);
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
