// Copyright 2026 Fries_I23
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../harness/webdav_server/webdav_authentication_fixture.dart';

void main() {
  final dart = File(
    '.flutter/bin/cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}',
  ).absolute.path;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('webdav-command-test-');
  });

  tearDown(() async {
    final pidFile = File('${directory.path}/child.pid');
    if (await pidFile.exists()) {
      Process.killPid(
        int.parse(await pidFile.readAsString()),
        ProcessSignal.sigkill,
      );
    }
    await directory.delete(recursive: true);
  });

  test('fixture commands capture output and preserve exit codes', () async {
    final script = File('${directory.path}/child.dart');
    await script.writeAsString('''
import 'dart:io';
void main() {
  stdout.write('output');
  stderr.write('error');
  exitCode = 7;
}
''');
    final result = await runWebDavFixtureCommand(dart, [
      script.path,
    ], workingDirectory: directory.path);
    expect(result.exitCode, 7);
    expect(result.stdout, 'output');
    expect(result.stderr, 'error');
  });

  test('timed out fixture commands exit before cleanup starts', () async {
    final script = File('${directory.path}/child.dart');
    await script.writeAsString(r'''
import 'dart:io';
import 'dart:isolate';
void main() {
  File('child.pid').writeAsStringSync('$pid');
  ReceivePort();
}
''');
    await expectLater(
      runWebDavFixtureCommand(
        dart,
        [script.path],
        workingDirectory: directory.path,
        timeout: const Duration(seconds: 2),
      ),
      throwsA(isA<TimeoutException>()),
    );
    final pidFile = File('${directory.path}/child.pid');
    expect(await pidFile.exists(), isTrue);
    final child = int.parse(await pidFile.readAsString());
    expect(Process.killPid(child), isFalse);
  });
}
