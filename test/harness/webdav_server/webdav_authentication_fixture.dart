// Copyright 2026 Fries_I23
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Runs a fixture command and stops it before reporting a timeout.
Future<ProcessResult> runWebDavFixtureCommand(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  Duration timeout = const Duration(minutes: 2),
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );
  final output = process.stdout.transform(utf8.decoder).join();
  final errors = process.stderr.transform(utf8.decoder).join();
  try {
    final (exitCode, stdout, stderr) = await (
      process.exitCode,
      output,
      errors,
    ).wait.timeout(timeout);
    return ProcessResult(process.pid, exitCode, stdout, stderr);
  } on TimeoutException {
    process.kill();
    try {
      await process.exitCode.timeout(const Duration(seconds: 1));
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await process.exitCode;
    }
    rethrow;
  }
}

class WebDavAuthenticationFixture {
  final Directory _appRoot;
  final String _project = 'mhabit-webdav-auth-$pid';
  bool _started = false;

  WebDavAuthenticationFixture() : _appRoot = Directory.current;

  Directory get _fixture =>
      Directory('${_appRoot.path}/test/harness/webdav_server/authentication');
  Directory get _tls => Directory('${_fixture.path}/tls');
  Directory get _results =>
      Directory('${_appRoot.path}/build/test-results/issue690');
  String get certificate => '${_tls.path}/ca.pem';

  Uri endpoint(String name, int defaultPort) => Uri.parse(
    'https://localhost:${Platform.environment['WEBDAV_${name.toUpperCase()}_PORT'] ?? defaultPort}/',
  );

  Future<ProcessResult> _run(String executable, List<String> arguments) async {
    final result = await runWebDavFixtureCommand(
      executable,
      arguments,
      workingDirectory: _appRoot.path,
    );
    if (result.exitCode != 0) {
      throw StateError(
        '$executable ${arguments.join(' ')} failed:\n'
        '${result.stdout}\n${result.stderr}',
      );
    }
    return result;
  }

  Future<ProcessResult> _compose(List<String> arguments) => _run('docker', [
    'compose',
    '-p',
    _project,
    '-f',
    '${_fixture.path}/compose.yml',
    ...arguments,
  ]);

  Future<void> start() async {
    await _results.create(recursive: true);
    await _run('docker', ['info']);
    await _tls.create(recursive: true);
    await _createCertificates();
    _started = true;
    final up = await _compose(['up', '-d']);
    await File(
      '${_results.path}/compose-up.log',
    ).writeAsString('${up.stdout}\n${up.stderr}');
    for (final entry in {
      'basic': 18341,
      'mixed': 18342,
      'digest': 18343,
    }.entries) {
      await _waitUntilReady(endpoint(entry.key, entry.value));
    }
    final images = await _compose(['images', '--format', 'json']);
    await File(
      '${_results.path}/images.json',
    ).writeAsString('${images.stdout}');
    final digests = await _run('docker', [
      'image',
      'inspect',
      'bytemark/webdav@sha256:21eed0df1238d17766080425f9ef46da2c1130e3e3aa9eaf36794d2a72e7c616',
      'nginx:1.28-alpine@sha256:a8b39bd9cf0f83869a2162827a0caf6137ddf759d50a171451b335cecc87d236',
      '--format',
      '{{.Id}} {{json .RepoDigests}}',
    ]);
    await File(
      '${_results.path}/image-digests.txt',
    ).writeAsString('${digests.stdout}');
  }

  Future<void> _createCertificates() async {
    final server = File('${_tls.path}/cert.pem');
    if (await File(certificate).exists() && await server.exists()) {
      final valid = await runWebDavFixtureCommand('openssl', [
        'x509',
        '-in',
        server.path,
        '-checkend',
        '3600',
        '-noout',
      ], workingDirectory: _appRoot.path);
      if (valid.exitCode == 0) return;
    }
    final caConfig = File('${_tls.path}/ca.cnf');
    await caConfig.writeAsString('''[req]
distinguished_name=dn
x509_extensions=extensions
prompt=no
[dn]
CN=WebDAV Regression CA
[extensions]
basicConstraints=critical,CA:TRUE
keyUsage=critical,keyCertSign,cRLSign
''');
    final extensions = File('${_tls.path}/server.cnf');
    await extensions.writeAsString('''subjectAltName=DNS:localhost,IP:127.0.0.1
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
''');
    await _run('openssl', [
      'req',
      '-x509',
      '-newkey',
      'rsa:2048',
      '-nodes',
      '-days',
      '7',
      '-keyout',
      '${_tls.path}/ca-key.pem',
      '-out',
      certificate,
      '-config',
      caConfig.path,
    ]);
    await _run('openssl', [
      'req',
      '-new',
      '-newkey',
      'rsa:2048',
      '-nodes',
      '-subj',
      '/CN=localhost',
      '-keyout',
      '${_tls.path}/key.pem',
      '-out',
      '${_tls.path}/server.csr',
    ]);
    await _run('openssl', [
      'x509',
      '-req',
      '-in',
      '${_tls.path}/server.csr',
      '-days',
      '7',
      '-CA',
      certificate,
      '-CAkey',
      '${_tls.path}/ca-key.pem',
      '-CAcreateserial',
      '-out',
      server.path,
      '-extfile',
      extensions.path,
    ]);
  }

  Future<void> _waitUntilReady(Uri uri) async {
    final context = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificates(certificate);
    for (var attempt = 0; attempt < 60; attempt++) {
      final client = HttpClient(context: context);
      try {
        final ready = await (() async {
          final response = await (await client.getUrl(uri)).close();
          final status = response.statusCode;
          if (uri.port == endpoint('mixed', 18342).port) {
            await File(
              '${_results.path}/mixed-401-headers.txt',
            ).writeAsString(response.headers.toString());
          }
          await response.drain<void>();
          return status == HttpStatus.unauthorized;
        })().timeout(const Duration(seconds: 2));
        if (ready) return;
      } on IOException {
        // Compose starts containers before Apache/Nginx are ready.
      } on TimeoutException {
        // Retry with a fresh connection within the readiness deadline.
      } finally {
        client.close(force: true);
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    throw StateError('WebDAV fixture did not become ready: $uri');
  }

  Future<void> stop() async {
    if (!_started) return;
    try {
      final logs = await _compose(['logs', '--no-color']);
      await File(
        '${_results.path}/compose.log',
      ).writeAsString('${logs.stdout}\n${logs.stderr}');
    } finally {
      await _compose(['down', '--volumes', '--remove-orphans']);
      _started = false;
    }
  }
}
