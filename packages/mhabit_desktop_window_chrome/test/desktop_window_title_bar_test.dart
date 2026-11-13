import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:mhabit_desktop_window_chrome/src/desktop_title_bar_api.g.dart';

class _Api implements DesktopWindowTitleBarApi {
  @override
  bool supported = true;
  bool colorsSupported = true;
  bool fail = false;
  Size? minimum;
  int resets = 0;
  final appearances = <DesktopTitleBarAppearance>[];
  final titles = <String>[];
  @override
  Future<void> setTitle(String title) async => titles.add(title);
  Completer<void>? blocked;

  @override
  Future<void> initialize({Size? minimumSize}) async => minimum = minimumSize;
  @override
  Future<bool> applyAppearance(DesktopTitleBarAppearance appearance) async {
    appearances.add(appearance);
    await blocked?.future;
    if (fail) throw StateError('native failure');
    return colorsSupported;
  }

  @override
  Future<void> reset() async => resets++;
}

const light = DesktopTitleBarAppearance(
  background: Color(0xFFF2F2F2),
  foreground: Color(0xFF112233),
  brightness: Brightness.light,
);
const dark = DesktopTitleBarAppearance(
  background: Color(0xFF112233),
  foreground: Color(0xFFF2F2F2),
  brightness: Brightness.dark,
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
    test(
      '$platform adapter sends resolved ARGB and applies the minimum',
      () async {
        debugDefaultTargetPlatformOverride = platform;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        const windowChannel = MethodChannel('window_manager');
        const prefix =
            'dev.flutter.pigeon.mhabit_desktop_window_chrome.DesktopTitleBarHostApi';
        const codec = DesktopTitleBarHostApi.pigeonChannelCodec;
        Map<Object?, Object?>? minimum;
        List<Object?>? payload;
        var resets = 0;
        String? title;
        binding.defaultBinaryMessenger.setMockMethodCallHandler(windowChannel, (
          call,
        ) async {
          if (call.method == 'setTitle') {
            title = (call.arguments as Map)['title'] as String;
          }
          if (call.method == 'setMinimumSize') {
            minimum = call.arguments as Map<Object?, Object?>;
          }
          if (call.method == 'isVisible' || call.method == 'isFocused') {
            return false;
          }
          return null;
        });
        binding.defaultBinaryMessenger.setMockMessageHandler(
          '$prefix.setAppearance',
          (message) async {
            payload = codec.decodeMessage(message) as List<Object?>;
            return codec.encodeMessage([true]);
          },
        );
        binding.defaultBinaryMessenger.setMockMessageHandler('$prefix.reset', (
          _,
        ) async {
          resets++;
          return codec.encodeMessage([null]);
        });
        addTearDown(() {
          binding.defaultBinaryMessenger.setMockMethodCallHandler(
            windowChannel,
            null,
          );
          binding.defaultBinaryMessenger.setMockMessageHandler(
            '$prefix.setAppearance',
            null,
          );
          binding.defaultBinaryMessenger.setMockMessageHandler(
            '$prefix.reset',
            null,
          );
        });
        final owner = DesktopWindowTitleBar();
        await owner.initialize(minimumSize: const Size(350, 520));
        await owner.setTitle('桌上习惯');
        expect(title, '桌上习惯');
        await owner.applyAppearance(dark);
        expect(minimum!['width'], 350.0);
        expect(minimum!['height'], 520.0);
        expect(payload, [0xFF112233, 0xFFF2F2F2, true]);
        await owner.dispose();
        expect(resets, 1);
      },
    );
  }

  group('Windows native foreground', () {
    const windowChannel = MethodChannel('window_manager');
    const foregroundChannel =
        'dev.flutter.pigeon.mhabit_desktop_window_chrome.'
        'DesktopTitleBarFlutterApi.foregroundChanged';
    late DesktopWindowTitleBar owner;
    late bool visible;
    late bool focused;
    (bool, bool)? shownState;
    String? failedQuery;
    Completer<bool>? pendingFocus;
    Completer<void>? focusStarted;
    late List<String> calls;

    Future<Object?> emit(bool foreground) async {
      final response = Completer<Object?>();
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        foregroundChannel,
        const StandardMessageCodec().encodeMessage([foreground]),
        (reply) => response.complete(
          const StandardMessageCodec().decodeMessage(reply),
        ),
      );
      return response.future;
    }

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      visible = false;
      focused = false;
      shownState = null;
      failedQuery = null;
      pendingFocus = null;
      focusStarted = null;
      calls = [];
      binding.defaultBinaryMessenger.setMockMethodCallHandler(windowChannel, (
        call,
      ) async {
        calls.add(call.method);
        if (call.method == failedQuery) {
          throw PlatformException(code: 'query-failed');
        }
        switch (call.method) {
          case 'isVisible':
            return visible;
          case 'isFocused':
            if (focusStarted case final started? when !started.isCompleted) {
              started.complete();
            }
            return pendingFocus == null ? focused : pendingFocus!.future;
          case 'isMinimized':
            return false;
          case 'focus':
            if (shownState case final state?) {
              (visible, focused) = state;
            }
        }
        return null;
      });
      owner = DesktopWindowTitleBar(api: _Api());
    });

    tearDown(() async {
      if (pendingFocus case final pending? when !pending.isCompleted) {
        pending.complete(false);
      }
      await owner.dispose();
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        windowChannel,
        null,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    for (final state in [(true, true), (true, false), (false, true)]) {
      test('initial snapshot requires visible and focused: $state', () async {
        (visible, focused) = state;
        expect(owner.foreground!.value, isFalse);
        await owner.initialize();
        expect(owner.foreground!.value, state.$1 && state.$2);
      });

      test('show samples actual state after native ACK: $state', () async {
        await owner.initialize();
        shownState = state;
        calls.clear();
        await owner.show();
        expect(owner.foreground!.value, state.$1 && state.$2);
        expect(calls, contains('isVisible'));
        if (state.$1) expect(calls, contains('isFocused'));
      });
    }

    test('native callbacks publish actual state without resampling', () async {
      await owner.initialize();
      final callsBeforeCallback = calls.length;
      expect(await emit(true), isEmpty);
      expect(owner.foreground!.value, isTrue);
      expect(await emit(false), isEmpty);
      expect(owner.foreground!.value, isFalse);
      expect(calls.length, callsBeforeCallback);
    });

    for (final foreground in [true, false]) {
      test('native callback rejects a stale snapshot: $foreground', () async {
        visible = true;
        pendingFocus = Completer<bool>();
        focusStarted = Completer<void>();
        final initialized = owner.initialize();
        await focusStarted!.future;
        expect(await emit(foreground), isEmpty);
        expect(owner.foreground!.value, foreground);
        pendingFocus!.complete(!foreground);
        await initialized;
        expect(owner.foreground!.value, foreground);
      });
    }

    for (final method in ['isVisible', 'isFocused']) {
      test('$method errors remain conservatively unfocused', () async {
        visible = true;
        focused = true;
        failedQuery = method;
        await owner.initialize();
        expect(owner.foreground!.value, isFalse);
        await emit(true);
        expect(owner.foreground!.value, isTrue);
      });
    }

    test(
      'dispose unbinds callbacks and rejects an in-flight snapshot',
      () async {
        visible = true;
        pendingFocus = Completer<bool>();
        focusStarted = Completer<void>();
        final initialized = owner.initialize();
        await focusStarted!.future;
        final foreground = owner.foreground!;
        await owner.dispose();
        expect(await emit(true), isNull);
        owner.foregroundChanged(true);
        pendingFocus!.complete(true);
        await initialized;
        expect(foreground.value, isFalse);
      },
    );
  });

  for (final platform in [TargetPlatform.linux, TargetPlatform.macOS]) {
    test('$platform exposes no Windows foreground source', () async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final owner = DesktopWindowTitleBar(api: _Api());
      expect(owner.foreground, isNull);
      await owner.initialize();
      await owner.dispose();
    });
  }

  test(
    'titles coalesce without canceling appearance and stop after dispose',
    () async {
      final api = _Api()..blocked = Completer<void>();
      final owner = DesktopWindowTitleBar(api: api);
      await owner.initialize();
      final appearance = owner.applyAppearance(dark);
      await Future<void>.delayed(Duration.zero);
      owner.setTitle('Table Habit');
      final latest = owner.setTitle('桌上习惯');
      api.blocked!.complete();
      await appearance;
      await latest;
      await owner.setTitle('桌上习惯');
      expect(api.titles, ['桌上习惯']);
      expect(api.appearances, [dark]);
      await owner.dispose();
      await owner.setTitle('Table Habit');
      expect(api.titles, ['桌上习惯']);
    },
  );

  test('minimum frame constraint and appearance deduplication', () async {
    final api = _Api();
    final owner = DesktopWindowTitleBar(api: api);
    await owner.initialize(minimumSize: const Size(350, 520));
    expect(api.minimum, const Size(350, 520));
    await owner.applyAppearance(light);
    await owner.applyAppearance(light);
    expect(api.appearances, [light]);
    expect(owner.lastCustomColorsApplied, true);
    await owner.dispose();
    await owner.dispose();
    expect(api.resets, 1);
  });

  test('queued stale changes are skipped and latest colors win', () async {
    final api = _Api()..blocked = Completer<void>();
    final owner = DesktopWindowTitleBar(api: api);
    await owner.initialize();
    final first = owner.applyAppearance(light);
    await Future<void>.delayed(Duration.zero);
    owner.applyAppearance(dark);
    final latest = owner.applyAppearance(light);
    api.blocked!.complete();
    await first;
    await latest;
    expect(api.appearances, [light, light]);
    await owner.dispose();
  });

  test(
    'unsupported colors retain native title bar and do not retry endlessly',
    () async {
      final api = _Api()..colorsSupported = false;
      final owner = DesktopWindowTitleBar(api: api);
      await owner.initialize();
      await owner.applyAppearance(dark);
      await owner.applyAppearance(dark);
      expect(owner.lastCustomColorsApplied, false);
      expect(api.appearances, [dark]);
      await owner.dispose();
    },
  );

  test(
    'native failure restores system colors and allows a later retry',
    () async {
      final api = _Api()..fail = true;
      final owner = DesktopWindowTitleBar(api: api);
      await owner.initialize();
      await owner.applyAppearance(light);
      expect(api.resets, 1);
      api.fail = false;
      await owner.applyAppearance(light);
      expect(api.appearances, [light, light]);
      await owner.dispose();
    },
  );

  test('dispose waits for in-flight changes and drops queued work', () async {
    final api = _Api()..blocked = Completer<void>();
    final owner = DesktopWindowTitleBar(api: api);
    await owner.initialize();
    owner.applyAppearance(light);
    await Future<void>.delayed(Duration.zero);
    owner.applyAppearance(dark);
    final disposed = owner.dispose();
    expect(api.resets, 0);
    api.blocked!.complete();
    await disposed;
    await owner.applyAppearance(dark);
    expect(api.appearances, [light]);
    expect(api.resets, 1);
  });

  test(
    'other platforms open no native channels; invalid minimum rejected',
    () async {
      final api = _Api()..supported = false;
      final owner = DesktopWindowTitleBar(api: api);
      await owner.initialize();
      await owner.applyAppearance(light);
      await owner.dispose();
      expect(api.appearances, isEmpty);
      expect(api.resets, 0);
      expect(owner.initialize(minimumSize: Size.zero), throwsArgumentError);
    },
  );
}
