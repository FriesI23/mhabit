// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/habit_widget/entry.dart';
import 'package:mhabit/entries/habit_widget/habit_widget_api.g.dart';
import 'package:mhabit/models/habit_date.dart';
import 'package:mhabit/models/habit_widget.dart';

const _backgroundChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.mhabit.HabitWidgetBackgroundApi.perform',
  HabitWidgetBackgroundApi.pigeonChannelCodec,
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
}
