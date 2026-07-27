// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_event.dart';
import 'package:mhabit/providers/workflow/app_event.dart';

/// A simple subscriber that records handleEvent calls.
class _TestSubscriber implements AppEventSubscriber {
  final List<AppEvent> handleEventCalls = [];

  @override
  bool shouldReceive(AppEvent event) => true;

  @override
  void handleEvent(AppEvent event) {
    handleEventCalls.add(event);
  }
}

/// A subscriber that filters out events from [AppEventPageSource.appSetting].
class _FilteringSubscriber implements AppEventSubscriber {
  final List<AppEvent> received = [];

  @override
  bool shouldReceive(AppEvent event) =>
      !event.isInTrace(AppEventPageSource.appSetting);

  @override
  void handleEvent(AppEvent event) {
    received.add(event);
  }
}

/// Helper to collect events of type [T] from [bus.on].
StreamSubscription<T> listenFor<T extends AppEvent>(
  AppEventBus bus,
  List<T> out,
) => bus.on<T>().listen(out.add);

void main() {
  group('AppEventBus', () {
    test('push and on deliver events', () async {
      final bus = AppEventBus();
      final events = <AppEvent>[];
      bus.on<AppEvent>().listen(events.add);

      bus.push(const ReloadDataEvent(msg: 'a'));
      bus.push(const ReloadDataEvent(msg: 'b'));

      await Future<void>.delayed(Duration.zero);

      expect(events.length, 2);
    });

    test('subscribe with default handleEvent', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      bus.subscribe<ReloadDataEvent>(sub);
      bus.push(const ReloadDataEvent(msg: 'x'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls.length, 1);
    });

    test('subscribe with custom onEvent', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      final custom = <ReloadDataEvent>[];
      bus.subscribe<ReloadDataEvent>(sub, onEvent: custom.add);
      bus.push(const ReloadDataEvent(msg: 'y'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls, isEmpty, reason: 'custom handler used');
      expect(custom.length, 1);
    });

    test('subscribe filters by type', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      bus.subscribe<ReloadDataEvent>(sub);
      bus.push(const GroupChangedEvent(uuidList: ['g1']));
      bus.push(const ReloadDataEvent(msg: 'r'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls.length, 1);
      expect(sub.handleEventCalls[0], isA<ReloadDataEvent>());
    });

    test('subscribe filters by shouldReceive', () async {
      final bus = AppEventBus();
      final sub = _FilteringSubscriber();
      bus.subscribe<AppEvent>(sub);

      bus.push(
        const ReloadDataEvent(
          msg: 'filtered',
          trace: {
            AppEventPageSource.appSetting: {
              AppEventFunctionSource.habitCreated,
            },
          },
        ),
      );
      bus.push(const ReloadDataEvent(msg: 'pass'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.received.length, 1);
    });

    test('on<T> still works (backward compat)', () async {
      final bus = AppEventBus();
      final events = <ReloadDataEvent>[];
      bus.on<ReloadDataEvent>().listen(events.add);

      bus.push(const ReloadDataEvent(msg: 'compat'));

      await Future<void>.delayed(Duration.zero);
      expect(events.length, 1);
      expect(events[0].msg, 'compat');
    });
  });

  group('AppEventSubscriptions', () {
    test('subscribe creates and delivers event', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      final subs = AppEventSubscriptions(sub, bus);

      subs.subscribe<ReloadDataEvent>();
      bus.push(const ReloadDataEvent(msg: 's1'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls.length, 1);
    });

    test('re-subscribe replaces existing subscription', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      final subs = AppEventSubscriptions(sub, bus);

      subs.subscribe<ReloadDataEvent>();
      subs.subscribe<ReloadDataEvent>(); // re-register
      bus.push(const ReloadDataEvent(msg: 'only-once'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls.length, 1, reason: 'duplicate not delivered');
    });

    test('cancel removes subscription', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      final subs = AppEventSubscriptions(sub, bus);

      subs.subscribe<ReloadDataEvent>();
      subs.cancel<ReloadDataEvent>();
      bus.push(const ReloadDataEvent(msg: 'lost'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls, isEmpty);
    });

    test('cancelAll removes all subscriptions', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      final subs = AppEventSubscriptions(sub, bus);

      subs.subscribe<ReloadDataEvent>();
      subs.subscribe<GroupChangedEvent>();
      subs.cancelAll();

      bus.push(const ReloadDataEvent(msg: 'a'));
      bus.push(const GroupChangedEvent(uuidList: ['b']));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls, isEmpty);
    });

    test('subscribe with custom onEvent bypasses handleEvent', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      final custom = <ReloadDataEvent>[];
      final subs = AppEventSubscriptions(sub, bus);

      subs.subscribe<ReloadDataEvent>(onEvent: custom.add);
      bus.push(const ReloadDataEvent(msg: 'custom'));

      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls, isEmpty);
      expect(custom.length, 1);
    });

    test('push delegates to AppEventBus', () async {
      final bus = AppEventBus();
      final sub = _TestSubscriber();
      final subs = AppEventSubscriptions(sub, bus);
      subs.subscribe<ReloadDataEvent>();

      subs.push(const ReloadDataEvent(msg: 'via-subs'));
      await Future<void>.delayed(Duration.zero);
      expect(sub.handleEventCalls.length, 1);
    });
  });
}
