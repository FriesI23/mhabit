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
