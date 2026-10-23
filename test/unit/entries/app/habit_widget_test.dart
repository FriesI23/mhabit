// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/app/habit_widget.dart';
import 'package:mhabit/entries/habit_widget/habit_widget_api.g.dart';
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

const _foregroundChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.mhabit.HabitWidgetForegroundApi.changed',
  HabitWidgetForegroundApi.pigeonChannelCodec,
);
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
  Future<void> Function()? beforePublish;
  int attempts = 0;
  String? storedLocale;

  @override
  Future<String?> readLocale() async => storedLocale;

  @override
  Future<void> publish(HabitWidgetSnapshot snapshot) async {
    attempts++;
    await beforePublish?.call();
    snapshots.add(snapshot);
    storedLocale = snapshot.locale;
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
    bridge.sync(context, locale: L10n.of(context)?.localeName);
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

  testWidgets(
    'pending refreshes coalesce and recover after a rejected publish',
    (tester) async {
      final firstPublish = Completer<void>();
      final publisher = _SnapshotPublisher();
      publisher.beforePublish = () async {
        if (publisher.attempts == 1) await firstPublish.future;
      };
      final service = HabitWidgetService(
        database: _EmptyDBHelper(),
        habitsAccess: HabitsManager(),
        publisher: publisher,
      );
      final events = AppEventBus();
      addTearDown(events.dispose);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<HabitWidgetService>.value(value: service),
            ChangeNotifierProvider<AppEventBus>.value(value: events),
          ],
          child: const MaterialApp(
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            home: _BridgeHost(),
          ),
        ),
      );
      await tester.pump();
      expect(publisher.attempts, 1);
      for (var i = 0; i < 3; i++) {
        events.push(const ReloadDataEvent());
      }
      await tester.pump();
      expect(publisher.attempts, 1);

      firstPublish.completeError(StateError('first publish rejected'));
      await tester.pumpAndSettle();
      expect(publisher.attempts, 2);
      expect(publisher.snapshots, hasLength(1));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      events.push(const ReloadDataEvent());
      await tester.pumpAndSettle();
      expect(publisher.attempts, 2);
    },
  );

  testWidgets('initial null locale inherits the previous shared language', (
    tester,
  ) async {
    final publisher = _SnapshotPublisher()..storedLocale = 'zh_Hant';
    final service = HabitWidgetService(
      database: _EmptyDBHelper(),
      habitsAccess: HabitsManager(),
      publisher: publisher,
    );
    // AppPostInit can run before MaterialApp has supplied localization data.
    await tester.pumpWidget(
      Provider<HabitWidgetService>.value(
        value: service,
        child: const _BridgeHost(),
      ),
    );
    await tester.pumpAndSettle();
    expect(publisher.snapshots.single.locale, 'zh_Hant');
    expect(publisher.storedLocale, 'zh_Hant');
    expect(publisher.snapshots.single.toJson(), isNot(contains('strings')));
    expect(tester.takeException(), isNull);
  });

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
    expect(publisher.snapshots.last.locale, 'en');
    expect(publisher.snapshots.last.toJson(), isNot(contains('strings')));
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

    for (final locale in [
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      const Locale('ar'),
    ]) {
      published = publisher.snapshots.length;
      await tester.pumpWidget(app(locale));
      await tester.pumpAndSettle();
      expect(publisher.snapshots.length, greaterThan(published));

      expect(publisher.snapshots.last.locale, lookupL10n(locale).localeName);
      expect(publisher.snapshots.last.toJson(), isNot(contains('strings')));
    }

    await tester.pumpWidget(const SizedBox.shrink());
    published = publisher.snapshots.length;
    events.push(const ReloadDataEvent());
    dates.dateTime = HabitDate.now().addDays(2);
    await tester.pumpAndSettle();
    expect(publisher.snapshots.length, published);
    expect(tester.takeException(), isNull);
  });
}
