// Copyright 2025 Fries_I23
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

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/app_event.dart';

class AppEventBus extends ChangeNotifier {
  final _controller = StreamController<AppEvent>.broadcast();

  Stream<T> on<T extends AppEvent>() => _controller.stream.whereType<T>();

  /// Subscribe to events of type [T], delegating self-exclusion filtering
  /// to [subscriber.shouldReceive].
  ///
  /// When [onEvent] is omitted, [subscriber.handleEvent] is used as the
  /// default handler.
  StreamSubscription<T> subscribe<T extends AppEvent>(
    AppEventSubscriber subscriber, {
    void Function(T event)? onEvent,
  }) {
    final handler = onEvent ?? subscriber.handleEvent;
    return _controller.stream
        .whereType<T>()
        .where(subscriber.shouldReceive)
        .listen(handler);
  }

  void push(AppEvent event) {
    _controller.add(event);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

abstract interface class AppEventLoaded {
  void updateAppEvent(AppEventBus newAppEvent);
}

/// Contract for event consumers that subscribe to [AppEventBus].
///
/// [shouldReceive] controls self-exclusion filtering; [handleEvent] provides
/// compile-time exhaustiveness via a sealed-class switch. When a new
/// [AppEvent] subtype is added, the switch in every override fails to
/// compile, forcing an explicit decision on how to handle it.
abstract interface class AppEventSubscriber {
  /// Return `true` if this subscriber should process [event].
  ///
  /// Typical implementation excludes self-originated events:
  /// ```dart
  /// bool shouldReceive(AppEvent event) =>
  ///     !event.isInTrace(AppEventPageSource.groupManage);
  /// ```
  bool shouldReceive(AppEvent event);

  /// Handle an [AppEvent] from the event bus.
  ///
  /// Override with a switch on all sealed subtypes; use `_unhandled` or
  /// `_ignore` markers for types this consumer does not need to react to.
  void handleEvent(AppEvent event);
}

/// Manages a collection of typed event subscriptions for an
/// [AppEventSubscriber].
///
/// Encapsulates the subscribe/cancel lifecycle and provides [push] delegation
/// so consumers don't need to hold a separate [AppEventBus] reference.
/// Re-subscribing to the same type automatically cancels the previous
/// subscription and creates a new one.
class AppEventSubscriptions {
  final AppEventSubscriber _subscriber;
  final AppEventBus _bus;
  final _subscriptions = <Type, StreamSubscription>{};

  AppEventSubscriptions(this._subscriber, this._bus);

  /// Subscribe to [T] events. Any existing subscription for [T] is cancelled
  /// first (re-register semantics).
  ///
  /// When [onEvent] is omitted, [_subscriber.handleEvent] is used.
  void subscribe<T extends AppEvent>({void Function(T event)? onEvent}) {
    _subscriptions.remove(T)?.cancel();
    _subscriptions[T] = _bus.subscribe<T>(_subscriber, onEvent: onEvent);
  }

  /// Push an event onto the bus. Convenience delegation to
  /// [_bus.push].
  void push(AppEvent event) => _bus.push(event);

  /// Cancel the subscription for [T], if any.
  void cancel<T extends AppEvent>() {
    _subscriptions.remove(T)?.cancel();
  }

  /// Cancel all subscriptions.
  void cancelAll() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}
