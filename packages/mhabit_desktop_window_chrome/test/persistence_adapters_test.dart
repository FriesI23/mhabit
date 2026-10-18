import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';
import 'package:mhabit_desktop_window_chrome/src/persistence/window_persistence_api.g.dart';

final _windowsState = WindowsWindowState(
  left: -1200,
  top: 30,
  width: 900,
  height: 650,
  dpi: 144,
  monitorLeft: -1920,
  monitorTop: 0,
  workWidth: 1920,
  workHeight: 1040,
);
final _linuxState = LinuxWindowState(width: 800, height: 600);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const codec = WindowPersistenceHostApi.pigeonChannelCodec;
  const prefix =
      'dev.flutter.pigeon.mhabit_desktop_window_chrome.WindowPersistenceHostApi';
  final restored = <Object>[];
  Object? snapshot;
  final nativeCalls = <String>[];
  var shouldRestore = true;
  final preferences = <String, String>{};

  DesktopWindowStateStore<T> store<T extends Object>(
    DesktopWindowStateFormat<T>? format,
  ) => format!.createStore(
    read: (key) => preferences[key],
    write: (key, value) async {
      preferences[key] = value;
      return true;
    },
  );

  setUp(() {
    snapshot = null;
    nativeCalls.clear();
    shouldRestore = true;
    restored.clear();
    preferences.clear();
    binding.defaultBinaryMessenger.setMockMessageHandler('$prefix.initialize', (
      _,
    ) async {
      nativeCalls.add('initialize');
      return codec.encodeMessage([shouldRestore]);
    });
    for (final platform in ['Windows', 'Linux']) {
      final geometryPrefix =
          'dev.flutter.pigeon.mhabit_desktop_window_chrome.${platform}WindowPersistenceHostApi';
      binding.defaultBinaryMessenger.setMockMessageHandler(
        '$geometryPrefix.restore',
        (message) async {
          nativeCalls.add('restore');
          final arguments = codec.decodeMessage(message) as List<Object?>;
          restored.add(arguments.first!);
          return codec.encodeMessage([null]);
        },
      );
      binding.defaultBinaryMessenger.setMockMessageHandler(
        '$geometryPrefix.capture',
        (message) async {
          nativeCalls.add('capture');
          return codec.encodeMessage([snapshot]);
        },
      );
    }
    binding.defaultBinaryMessenger.setMockMessageHandler('$prefix.flush', (
      _,
    ) async {
      nativeCalls.add('flush');
      return codec.encodeMessage([null]);
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    for (final method in ['initialize', 'flush']) {
      binding.defaultBinaryMessenger.setMockMessageHandler(
        '$prefix.$method',
        null,
      );
    }
    for (final platform in ['Windows', 'Linux']) {
      for (final method in ['restore', 'capture']) {
        binding.defaultBinaryMessenger.setMockMessageHandler(
          'dev.flutter.pigeon.mhabit_desktop_window_chrome.${platform}WindowPersistenceHostApi.$method',
          null,
        );
      }
    }
  });

  test(
    'Windows state preserves native DPI and workspace coordinates',
    () async {
      final adapter =
          createAdapter(TargetPlatform.windows)
              as StoredWindowPersistenceAdapter;
      snapshot = _windowsState;
      final state = await adapter.captureState();
      expect(state, _windowsState);
      await adapter.restoreState(state!);
      expect(restored.single, snapshot);
    },
  );

  test('Linux state has a position only when supplied by GTK', () async {
    final adapter =
        createAdapter(TargetPlatform.linux) as StoredWindowPersistenceAdapter;
    snapshot = _linuxState;
    final waylandState = (await adapter.captureState())! as LinuxWindowState;
    expect(waylandState.position, isNull);
    await adapter.restoreState(waylandState);
    expect(restored.single, _linuxState);
    restored.clear();
    snapshot = LinuxWindowState(
      width: 800,
      height: 600,
      position: LinuxWindowPosition(x: -500, y: 100),
    );
    final x11State = (await adapter.captureState())! as LinuxWindowState;
    expect(x11State.position, LinuxWindowPosition(x: -500, y: 100));
    await adapter.restoreState(x11State);
    expect(restored.single, snapshot);
  });

  test(
    'store constructs Windows state from the existing v1 pref format',
    () async {
      const key = 'desktop.window.windows.v1';
      // Existing records can contain integer JSON numbers.
      preferences[key] =
          '{"version":1,"left":-1200,"top":30,"width":900,'
          '"height":650,"dpi":144,"monitorLeft":-1920,"monitorTop":0,'
          '"workWidth":1920,"workHeight":1040}';
      final states = store(DesktopWindowStateFormat.windowsPlacement);
      final state = states.get();
      expect(state, _windowsState);
      expect(state.hashCode, _windowsState.hashCode);
      expect(await states.set(state!), isTrue);
      expect(jsonDecode(preferences[key]!), {
        'version': 1,
        'left': -1200,
        'top': 30,
        'width': 900,
        'height': 650,
        'dpi': 144,
        'monitorLeft': -1920,
        'monitorTop': 0,
        'workWidth': 1920,
        'workHeight': 1040,
      });
      expect(preferences.keys, [key]);
    },
  );

  test(
    'store constructs Linux states and replaces X11 position with size only',
    () async {
      const key = 'desktop.window.linux.v1';
      preferences[key] =
          '{"version":1,"width":800,"height":600,"x":-500,"y":100}';
      final states = store(DesktopWindowStateFormat.gtkGeometry);
      final positioned = LinuxWindowState(
        width: 800,
        height: 600,
        position: LinuxWindowPosition(x: -500, y: 100),
      );
      expect(states.get(), positioned);
      expect(await states.set(positioned), isTrue);
      expect(jsonDecode(preferences[key]!), {
        'version': 1,
        'width': 800,
        'height': 600,
        'x': -500,
        'y': 100,
      });
      expect(await states.set(_linuxState), isTrue);
      expect(jsonDecode(preferences[key]!), {
        'version': 1,
        'width': 800,
        'height': 600,
      });
      expect(states.get(), _linuxState);
      expect(preferences.keys, [key]);
    },
  );

  test(
    'missing, corrupt and unsupported records never reach native restore',
    () async {
      for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
        final adapter = createAdapter(platform);
        final states = store(adapter.stateFormat);
        expect(states.get(), isNull);
        final key = platform == TargetPlatform.windows
            ? 'desktop.window.windows.v1'
            : 'desktop.window.linux.v1';
        for (final record in [
          'broken',
          'null',
          '[]',
          '{"version":2}',
          '{"version":1,"width":-1,"height":600}',
          '{"version":1,"width":"800","height":600}',
          '{"version":1,"width":1e999,"height":600}',
          '{"version":1,"width":800,"height":0}',
        ]) {
          preferences[key] = record;
          final state = states.get();
          expect(state, isNull);
          await adapter.initialize(
            'main-window',
            const Size(350, 520),
            store: states,
          );
        }
        preferences.clear();
      }
      expect(restored, isEmpty);
    },
  );

  test('invalid Windows DPI or monitor metadata is discarded', () {
    final states = store(DesktopWindowStateFormat.windowsPlacement);
    final valid = {
      'version': 1,
      'left': 0,
      'top': 0,
      'width': 800,
      'height': 600,
      'dpi': 96,
      'monitorLeft': 0,
      'monitorTop': 0,
      'workWidth': 1920,
      'workHeight': 1040,
    };
    for (final field in ['dpi', 'workWidth', 'workHeight']) {
      preferences['desktop.window.windows.v1'] = jsonEncode({
        ...valid,
        field: 0,
      });
      expect(states.get(), isNull);
      preferences['desktop.window.windows.v1'] = jsonEncode(
        {...valid}..remove(field),
      );
      expect(states.get(), isNull);
    }
  });

  test('incomplete Linux position degrades to size only', () {
    final states = store(DesktopWindowStateFormat.gtkGeometry);
    for (final position in ['"x":20', '"x":"bad","y":10']) {
      preferences['desktop.window.linux.v1'] =
          '{"version":1,"width":800,"height":600,$position}';
      expect(states.get(), _linuxState);
    }
  });

  test('store rejects mismatched state and invalid dimensions', () async {
    final windows = store(DesktopWindowStateFormat.windowsPlacement);
    final linux = store(DesktopWindowStateFormat.gtkGeometry);
    expect(
      () => (windows as dynamic).set(_linuxState),
      throwsA(isA<TypeError>()),
    );
    expect(
      () => (linux as dynamic).set(_windowsState),
      throwsA(isA<TypeError>()),
    );
    expect(await linux.set(LinuxWindowState(width: -1, height: 600)), isFalse);
    expect(
      await linux.set(LinuxWindowState(width: double.nan, height: 600)),
      isFalse,
    );
    expect(preferences, isEmpty);
  });

  test('storage failures and write results remain observable', () async {
    final failure = StateError('backend unavailable');
    final states = DesktopWindowStateStore(
      format: DesktopWindowStateFormat.gtkGeometry,
      read: (_) => throw failure,
      write: (_, _) => Future.error(failure),
    );
    expect(states.get, throwsA(same(failure)));
    await expectLater(states.set(_linuxState), throwsA(same(failure)));
    final unavailable = DesktopWindowStateStore(
      format: DesktopWindowStateFormat.gtkGeometry,
      read: (_) => null,
      write: (_, _) async => false,
    );
    expect(await unavailable.set(_linuxState), isFalse);
  });

  test(
    'AppKit implementation flushes natively without accessing a store',
    () async {
      final adapter = createAdapter(TargetPlatform.macOS);
      expect(adapter.stateFormat, isNull);
      expect(adapter.managesClose, false);
      final states = ForbiddenStore();
      await adapter.initialize(
        'main-window',
        const Size(350, 520),
        store: states,
      );
      await adapter.flush(states);
      expect(nativeCalls, ['initialize', 'flush']);
      expect(restored, isEmpty);
      expect(preferences, isEmpty);
    },
  );

  test('store-backed implementations persist without a native flush', () async {
    for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
      final adapter = createAdapter(platform);
      final states = store(adapter.stateFormat);
      snapshot = platform == TargetPlatform.windows
          ? _windowsState
          : _linuxState;
      final expected = platform == TargetPlatform.windows
          ? _windowsState
          : _linuxState;
      nativeCalls.clear();
      await adapter.flush(states);
      expect(states.get(), expected);
      expect(nativeCalls, ['capture']);
      await adapter.initialize(
        'main-window',
        const Size(350, 520),
        store: states,
      );
      expect(restored.last, snapshot);
      preferences.clear();
    }
  });

  testWidgets('AppKit flush bounds the native wait', (tester) async {
    final pending = Completer<ByteData?>();
    binding.defaultBinaryMessenger.setMockMessageHandler(
      '$prefix.flush',
      (_) => pending.future,
    );
    final adapter = createAdapter(TargetPlatform.macOS);
    final result = expectLater(
      adapter.flush(ForbiddenStore()),
      throwsA(isA<TimeoutException>()),
    );
    await tester.pump(const Duration(seconds: 2));
    await result;
    pending.complete(codec.encodeMessage([null]));
    await tester.pump();
  });

  test(
    'visible stored windows skip reading and restoring pref geometry',
    () async {
      shouldRestore = false;
      for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
        nativeCalls.clear();
        final adapter = createAdapter(platform);
        await adapter.initialize(
          'main-window',
          const Size(350, 520),
          store: platform == TargetPlatform.windows
              ? ForbiddenStore<WindowsWindowState>()
              : ForbiddenStore<LinuxWindowState>(),
        );
        expect(nativeCalls, ['initialize']);
      }
    },
  );

  test(
    'null stored capture skips writing without selecting native persistence',
    () async {
      final adapter = createAdapter(TargetPlatform.linux);
      final states = store(adapter.stateFormat);
      await states.set(_linuxState);
      snapshot = null;
      await adapter.flush(states);
      expect(states.get(), _linuxState);
      expect(nativeCalls, ['capture']);
    },
  );

  test(
    'mobile and unsupported platforms do not initialize a native window',
    () async {
      for (final platform in [
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.fuchsia,
      ]) {
        final adapter = createAdapter(platform);
        expect(adapter.supported, isFalse);
        expect(adapter.stateFormat, isNull);
        await adapter.initialize('main-window', const Size(350, 520));
      }
    },
  );
}

DesktopWindowPersistenceAdapter createAdapter(TargetPlatform platform) {
  final previous = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform;
  try {
    return DesktopWindowPersistenceAdapter.create();
  } finally {
    debugDefaultTargetPlatformOverride = previous;
  }
}

class ForbiddenStore<T extends Object> implements DesktopWindowStateStore<T> {
  @override
  T? get() => throw StateError('unexpected store read');

  @override
  Future<bool> set(T state) => throw StateError('unexpected store write');
}
