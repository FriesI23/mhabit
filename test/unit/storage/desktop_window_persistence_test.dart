import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/async.dart';
import 'package:mhabit/storage/desktop_window_persistence.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart'
    show
        DesktopWindowPersistenceAdapter,
        DesktopWindowStateFormat,
        DesktopWindowStateStore,
        WindowsWindowState;
import 'package:shared_preferences/shared_preferences.dart';

final _state = WindowsWindowState(
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
const _record =
    '{"version":1,"left":-1200.0,"top":30.0,"width":900.0,'
    '"height":650.0,"dpi":144.0,"monitorLeft":-1920.0,"monitorTop":0.0,'
    '"workWidth":1920.0,"workHeight":1040.0}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterExceptionHandler? previousErrorHandler;
  late List<FlutterErrorDetails> reported;
  late WindowAdapter adapter;
  late DesktopWindowPersistence windows;

  setUp(() {
    SharedPreferences.setMockInitialValues({'profile.setting': 'before'});
    adapter = WindowAdapter();
    windows = DesktopWindowPersistence.forTesting(adapter: adapter);
    reported = [];
    previousErrorHandler = FlutterError.onError;
    FlutterError.onError = reported.add;
  });

  tearDown(() async {
    await windows.dispose();
    FlutterError.onError = previousErrorHandler;
  });

  test('default constructor shares one process instance', () {
    expect(DesktopWindowPersistence(), same(DesktopWindowPersistence()));
    expect(windows, isNot(same(DesktopWindowPersistence())));
  });

  test(
    'concurrent initialization shares preference loading and native setup',
    () async {
      final pref = await SharedPreferences.getInstance();
      final pending = Completer<SharedPreferences>();
      var loads = 0;
      windows = DesktopWindowPersistence.forTesting(
        adapter: adapter,
        loadPreferences: () {
          loads++;
          return pending.future;
        },
      );
      final first = windows.init();
      final second = windows.init();
      expect(second, same(first));
      expect(loads, 1);
      pending.complete(pref);
      await Future.wait([first, second]);
      await windows.init();
      expect(loads, 1);
      expect(adapter.initializations, 1);
    },
  );

  test(
    'unsupported platforms skip preferences and native initialization',
    () async {
      adapter = WindowAdapter(supported: false);
      windows = DesktopWindowPersistence.forTesting(
        adapter: adapter,
        loadPreferences: () =>
            throw StateError('preferences must not be opened'),
      );
      await windows.init();
      expect(adapter.initializations, 0);
      expect(reported, isEmpty);
    },
  );

  test(
    'window and Profile preferences share the existing singleton cache',
    () async {
      final profilePreferences = await SharedPreferences.getInstance();
      final AsyncInitialization initialization = windows;
      await initialization.init();
      expect(adapter.store?.get(), isNull);
      expect(await (adapter.store?.set(_state) ?? Future.value(false)), isTrue);
      await profilePreferences.setString('profile.setting', 'after');
      expect(
        profilePreferences.getString('desktop.window.windows.v1'),
        _record,
      );
      expect(adapter.store?.get(), _state);
      expect(profilePreferences.getString('profile.setting'), 'after');
    },
  );

  for (final error in [
    StateError('preferences backend unavailable'),
    TimeoutException('preferences backend timed out'),
  ]) {
    test('backend $error propagates with its original stack', () async {
      final stack = StackTrace.fromString('preferences backend stack');
      windows = DesktopWindowPersistence.forTesting(
        adapter: adapter,
        loadPreferences: () => Future.error(error, stack),
      );
      Object? caught;
      StackTrace? caughtStack;
      try {
        await windows.init();
      } catch (error, stack) {
        caught = error;
        caughtStack = stack;
      }
      expect(caught, same(error));
      expect(caughtStack.toString(), stack.toString());
      expect(reported, isEmpty);
      expect(adapter.initializations, 0);
    });
  }

  testWidgets('window deadline reports and continues, then permits retry', (
    tester,
  ) async {
    final handler = FlutterError.onError;
    FlutterError.onError = reported.add;
    try {
      final pref = await SharedPreferences.getInstance();
      await pref.setString('desktop.window.windows.v1', _record);
      final pending = Completer<SharedPreferences>();
      windows = DesktopWindowPersistence.forTesting(
        adapter: adapter,
        loadPreferences: () => pending.future,
      );
      final initialization = windows.init();
      await tester.pump(const Duration(seconds: 2));
      await initialization;
      expect(reported, hasLength(1));
      expect(reported.single.exception, isA<TimeoutException>());
      expect(reported.single.stack, isNotNull);
      expect(reported.single.library, 'desktop window persistence');
      expect(adapter.initializations, 1);
      expect(adapter.store?.get(), isNull);
      expect(
        await (adapter.store?.set(_state) ?? Future.value(false)),
        isFalse,
      );

      pending.complete(pref);
      await tester.pump();
      expect(adapter.store?.get(), isNull);
      await windows.init();
      expect(adapter.store?.get(), _state);
      expect(await (adapter.store?.set(_state) ?? Future.value(false)), isTrue);
      expect(reported, hasLength(1));
      expect(adapter.initializations, 1);
    } finally {
      FlutterError.onError = handler;
    }
  });

  test(
    'corrupt window record keeps defaults and permits later saving',
    () async {
      final pref = await SharedPreferences.getInstance();
      await pref.setString('desktop.window.windows.v1', 'broken');
      await windows.init();
      expect(adapter.initializations, 1);
      expect(adapter.restored, isEmpty);
      expect(adapter.store?.get(), isNull);
      expect(reported, isEmpty);
      expect(await (adapter.store?.set(_state) ?? Future.value(false)), isTrue);
      expect(adapter.store?.get(), _state);
      expect(pref.getString('profile.setting'), 'before');
    },
  );

  test('native autosave initializes without opening preferences', () async {
    adapter = WindowAdapter(stateFormat: null);
    windows = DesktopWindowPersistence.forTesting(
      adapter: adapter,
      loadPreferences: () => throw StateError('preferences must not be opened'),
    );
    await windows.init();
    await windows.init();
    expect(adapter.initializations, 1);
    expect(reported, isEmpty);
  });

  test(
    'restores before init returns and cannot initialize after disposal',
    () async {
      final pref = await SharedPreferences.getInstance();
      await pref.setString('desktop.window.windows.v1', _record);
      await windows.init();
      expect(adapter.restored, [_state]);
      await windows.dispose();
      await windows.dispose();
      await windows.init();
      expect(adapter.initializations, 1);
      expect(adapter.disposals, 1);
    },
  );

  test(
    'disposal during preference loading prevents native initialization',
    () async {
      final pref = await SharedPreferences.getInstance();
      await pref.setString('desktop.window.windows.v1', _record);
      final pending = Completer<SharedPreferences>();
      windows = DesktopWindowPersistence.forTesting(
        adapter: adapter,
        loadPreferences: () => pending.future,
      );
      final initialization = windows.init();
      await windows.dispose();
      pending.complete(pref);
      await initialization;
      expect(adapter.initializations, 0);
      expect(adapter.disposals, 1);
    },
  );
}

class WindowAdapter
    implements DesktopWindowPersistenceAdapter<WindowsWindowState> {
  WindowAdapter({
    this.stateFormat = DesktopWindowStateFormat.windowsPlacement,
    this.supported = true,
  });

  @override
  final bool supported;

  @override
  final DesktopWindowStateFormat<WindowsWindowState>? stateFormat;
  DesktopWindowStateStore<WindowsWindowState>? store;
  int initializations = 0;
  int disposals = 0;
  final restored = <WindowsWindowState>[];

  @override
  bool get managesClose => false;

  @override
  Future<void> initialize(
    String name,
    Size minimumSize, {
    DesktopWindowStateStore<WindowsWindowState>? store,
    Duration operationTimeout = const Duration(seconds: 2),
  }) async {
    initializations++;
    this.store = store;
    final state = store?.get();
    if (state != null) restored.add(state);
  }

  @override
  Future<void> flush(
    DesktopWindowStateStore<WindowsWindowState>? store, {
    Duration operationTimeout = const Duration(seconds: 2),
  }) async {}

  @override
  Future<void> dispose() async => disposals++;
}
