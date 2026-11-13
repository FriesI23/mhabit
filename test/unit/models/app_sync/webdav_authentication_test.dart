// Copyright 2026 Fries_I23
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:simple_webdav_client/client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpServer server;
  late Uri root;
  late HttpOverrides? previousOverrides;
  late List<String> methods;
  late List<String?> authorization;
  late List<WebDavStdClient> clients;
  final expected = 'Basic ${base64Encode(utf8.encode('user:password'))}';

  WebDavStdClient build({
    String username = 'user',
    String password = 'password',
  }) {
    final result = WebDavAppSyncTask.buildWebDavClient(
      AppWebDavSyncServer.newServer(
        identity: 'auth-test',
        path: root.toString(),
        username: username,
        password: password,
        connectTimeout: const Duration(seconds: 2),
        maxRetryCount: 1,
      ),
    );
    clients.add(result);
    return result;
  }

  setUp(() async {
    previousOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    root = Uri.parse('http://127.0.0.1:${server.port}/');
    methods = [];
    authorization = [];
    clients = [];
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      methods.add(request.method);
      final auth = request.headers.value('Authorization');
      authorization.add(auth);
      if (auth == expected || request.uri.path == '/anonymous') {
        request.response.statusCode = request.method == 'PUT' ? 201 : 200;
        if (request.method == 'PUT') {
          expect(body, '{"habit":"测试"}');
          expect(request.headers.value('If-Match'), '"etag"');
          expect(request.headers.contentType?.mimeType, 'application/json');
        }
      } else {
        request.response.statusCode = 401;
        request.response.headers.set(
          'WWW-Authenticate',
          'Basic realm="test", Bearer resource_metadata="https://example.test/meta"',
        );
      }
      await request.response.close();
    });
  });

  tearDown(() async {
    for (final client in clients) {
      client.close(force: true);
    }
    await server.close(force: true);
    HttpOverrides.global = previousOverrides;
  });

  test(
    'existing server credentials automatically handle Basic + Bearer',
    () async {
      final client = build();
      expect(client.client, isA<HttpClientForWebDav>());
      expect(client.client.connectionTimeout, const Duration(seconds: 2));
      final response = await (await client.dispatch(root).get()).close();
      expect(response.response.statusCode, 200);
      await response.response.drain<void>();
      expect(methods, ['PROPFIND', 'GET']);
      expect(authorization, [null, expected]);
    },
  );

  test(
    'first PUT is sent once with complete JSON and conditional headers',
    () async {
      final request = await build()
          .dispatch(root.resolve('habit.json'))
          .create(data: '{"habit":"测试"}');
      request.request.headers.contentType = ContentType.json;
      request.request.headers.set('If-Match', '"etag"');
      request.request.contentLength = utf8.encode('{"habit":"测试"}').length;
      final response = await request.close();
      await response.response.drain<void>();
      expect(response.response.statusCode, 201);
      expect(methods, ['PROPFIND', 'PUT']);
    },
  );

  test('wrong stored password produces 401 without parser failure', () async {
    final response = await (await build(
      password: 'wrong',
    ).dispatch(root).get()).close();
    expect(response.response.statusCode, 401);
    await response.response.drain<void>();
    expect(methods, ['PROPFIND', 'GET']);
  });

  test('empty username preserves the anonymous client path', () async {
    final response = await (await build(
      username: '',
    ).dispatch(root.resolve('anonymous')).get()).close();
    expect(response.response.statusCode, 200);
    await response.response.drain<void>();
    expect(methods, ['GET']);
    expect(authorization, [null]);
  });
}
