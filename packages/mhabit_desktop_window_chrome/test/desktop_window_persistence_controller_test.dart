import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_desktop_window_chrome/mhabit_desktop_window_chrome.dart';

final _saved = LinuxWindowState(width: 800, height: 600);
final _ordinary = LinuxWindowState(width: 800, height: 600);
final _first = LinuxWindowState(width: 810, height: 600);
final _latest = LinuxWindowState(width: 820, height: 600);
final _second = LinuxWindowState(width: 830, height: 600);
final _last = LinuxWindowState(width: 840, height: 600);

class MemoryStore implements DesktopWindowStateStore<LinuxWindowState> {
  LinuxWindowState? record;
  final writes = <LinuxWindowState>[];
  final calls = <String>[];
  Completer<void>? blocked;
  bool failRead = false;
  bool failWrite = false;
  bool throwWrite = false;
  @override
  LinuxWindowState? get() {
    calls.add('read');
    if (failRead) throw StateError('read failed');
    return record;
  }

  @override
  Future<bool> set(LinuxWindowState value) async {
    calls.add('write:${value.width}');
    if (throwWrite) throw StateError('write failed');
    if (failWrite) return false;
    await blocked?.future;
    writes.add(value);
    record = value;
    return true;
  }
}

class PlacementAdapter
    extends StoredWindowPersistenceAdapter<LinuxWindowState> {
  PlacementAdapter(this.calls);
  final List<String> calls;
  bool restoreAllowed = true;
  bool shouldClose = true;
  bool failInitialize = false;
  LinuxWindowState? snapshot;
  Completer<LinuxWindowState?>? pendingCapture;
  int initializations = 0;
  @override
  bool get supported => true;
  @override
  DesktopWindowStateFormat<LinuxWindowState> get stateFormat =>
      DesktopWindowStateFormat.gtkGeometry;
  @override
  bool get managesClose => shouldClose;
  @override
  Future<bool> initializeWindow(String name, Size minimumSize) async {
    initializations++;
    calls.add('initialize');
    if (failInitialize) throw StateError('native unavailable');
    return restoreAllowed;
  }

  @override
  Future<void> restoreState(LinuxWindowState state) async =>
      calls.add('restore:${state.width}');
  @override
  Future<LinuxWindowState?> captureState() async {
    calls.add('capture');
    return pendingCapture == null ? snapshot : await pendingCapture!.future;
  }

  @override
  Future<void> dispose() async => calls.add('dispose');
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryStore store;
  late PlacementAdapter adapter;
  late DesktopWindowPersistenceController<LinuxWindowState> persistence;
  late List<String> windowCalls;

  setUp(() {
    store = MemoryStore();
    adapter = PlacementAdapter(store.calls);
    windowCalls = [];
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      (call) async {
        windowCalls.add('${call.method}:${call.arguments}');
        return null;
      },
    );
    persistence = DesktopWindowPersistenceController(
      store: store,
      adapter: adapter,
    );
  });

  tearDown(() async {
    store.blocked?.complete();
    store.blocked = null;
    await persistence.dispose();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      null,
    );
  });

  Future<void> initialize() =>
      persistence.initialize(minimumSize: const Size(350, 520));

  test(
    'initializes window manager before native placement without a title bar',
    () async {
      final counts = <int>[];
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('window_manager'),
        (call) async {
          if (call.method == 'ensureInitialized') {
            counts.add(adapter.initializations);
          }
          return null;
        },
      );
      await initialize();
      expect(counts, [0]);
      expect(adapter.initializations, 1);
    },
  );

  test('restores before returning and never displays the window', () async {
    store.record = _saved;
    await initialize();
    await initialize();
    expect(adapter.initializations, 1);
    expect(store.calls, ['initialize', 'read', 'restore:800.0']);
    expect(windowCalls, [
      'ensureInitialized:null',
      'setPreventClose:{isPreventClose: true}',
    ]);
  });

  test('hot restart does not read storage or restore visible window', () async {
    adapter.restoreAllowed = false;
    store.record = _saved;
    await initialize();
    expect(store.calls, ['initialize']);
  });

  test('missing record retains default placement', () async {
    await initialize();
    expect(store.calls, ['initialize', 'read']);
  });

  test('read failure still permits subsequent saves', () async {
    store.failRead = true;
    await initialize();
    adapter.snapshot = _ordinary;
    await persistence.flush();
    expect(store.writes, [_ordinary]);
  });

  test('unavailable storage keeps the window lifecycle operational', () async {
    persistence = DesktopWindowPersistenceController(adapter: adapter);
    adapter.snapshot = _ordinary;
    await initialize();
    await persistence.flush();
    expect(store.calls, ['initialize']);
    expect(windowCalls, [
      'ensureInitialized:null',
      'setPreventClose:{isPreventClose: true}',
    ]);
    expect(store.writes, isEmpty);
  });

  testWidgets('move and resize coalesce for 300 ms', (tester) async {
    await initialize();
    adapter.snapshot = _first;
    persistence.onWindowMove();
    await tester.pump(const Duration(milliseconds: 200));
    adapter.snapshot = _latest;
    persistence.onWindowResize();
    await tester.pump(const Duration(milliseconds: 299));
    expect(store.writes, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(store.writes, [_latest]);
  });

  test('serializes writes and merges concurrent flush requests', () async {
    await initialize();
    adapter.snapshot = _first;
    store.blocked = Completer<void>();
    final first = persistence.flush();
    await Future<void>.delayed(Duration.zero);
    adapter.snapshot = _second;
    final second = persistence.flush();
    final third = persistence.flush();
    expect(store.calls.where((call) => call.startsWith('write:')), [
      'write:810.0',
    ]);
    store.blocked!.complete();
    store.blocked = null;
    await Future.wait([first, second, third]);
    expect(store.writes, [_first, _second]);
    expect(store.record, _second);
  });

  test('equal captures skip duplicate writes by value', () async {
    await initialize();
    adapter.snapshot = _ordinary;
    await persistence.flush();
    final captured = LinuxWindowState(width: _ordinary.width, height: 600);
    expect(captured, isNot(same(_ordinary)));
    adapter.snapshot = captured;
    await persistence.flush();
    expect(store.writes, [_ordinary]);
  });

  testWidgets('slow store write stays serialized beyond the native deadline', (
    tester,
  ) async {
    await initialize();
    adapter.snapshot = _first;
    store.blocked = Completer<void>();
    final first = persistence.flush();
    await tester.pump(const Duration(seconds: 3));
    adapter.snapshot = _latest;
    final latest = persistence.flush();
    await tester.pump();
    expect(store.calls.where((call) => call == 'capture'), hasLength(1));
    expect(store.writes, isEmpty);
    store.blocked!.complete();
    store.blocked = null;
    await tester.pump();
    await Future.wait([first, latest]);
    expect(store.writes, [_first, _latest]);
    expect(store.record, _latest);
  });

  testWidgets('capture deadline permits retry and ignores its late result', (
    tester,
  ) async {
    await initialize();
    final pending = Completer<LinuxWindowState?>();
    adapter.pendingCapture = pending;
    final first = persistence.flush();
    await tester.pump(const Duration(seconds: 2));
    await first;
    adapter.pendingCapture = null;
    adapter.snapshot = _latest;
    await persistence.flush();
    pending.complete(_first);
    await tester.pump();
    expect(store.writes, [_latest]);
    expect(store.record, _latest);
  });

  test('non-ordinary native snapshot does not overwrite saved frame', () async {
    await initialize();
    adapter.snapshot = _ordinary;
    await persistence.flush();
    adapter.snapshot = null;
    await persistence.flush();
    expect(store.writes, [_ordinary]);
  });

  test('failed write is retried even if snapshot did not change', () async {
    await initialize();
    adapter.snapshot = _ordinary;
    store.failWrite = true;
    await persistence.flush();
    store.failWrite = false;
    await persistence.flush();
    expect(store.writes, [_ordinary]);
  });

  test('throwing write is retried without poisoning the save queue', () async {
    await initialize();
    adapter.snapshot = _ordinary;
    store.throwWrite = true;
    await persistence.flush();
    store.throwWrite = false;
    await persistence.flush();
    expect(store.writes, [_ordinary]);
  });

  testWidgets('close flush has a bounded deadline and continues native close', (
    tester,
  ) async {
    await initialize();
    adapter.snapshot = _last;
    store.blocked = Completer<void>();
    persistence.onWindowClose();
    persistence.onWindowClose();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(
      windowCalls.where((call) => call.startsWith('close:')),
      hasLength(1),
    );
    expect(windowCalls, contains('setPreventClose:{isPreventClose: false}'));
    store.blocked!.complete();
    store.blocked = null;
    await tester.pump();
  });

  test('native close ownership skips Dart close interception', () async {
    adapter.shouldClose = false;
    await initialize();
    persistence.onWindowClose();
    await Future<void>.delayed(Duration.zero);
    expect(windowCalls, isEmpty);
  });

  test('dispose is idempotent and removes pending timers', () async {
    await initialize();
    adapter.snapshot = _last;
    persistence.onWindowMove();
    await persistence.dispose();
    await persistence.dispose();
    await initialize();
    expect(store.writes, [_last]);
    expect(store.calls.where((call) => call == 'dispose'), hasLength(1));
    expect(adapter.initializations, 1);
  });
}
