// Copyright (c) 2026 Fries_I23
// SPDX-License-Identifier: MIT

@Timeout(Duration(minutes: 3))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simple_webdav_client/client.dart';
import 'package:simple_webdav_client/utils.dart';

import 'webdav_authentication_fixture.dart';
import 'webdav_sync_extras_live_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final enabled = Platform.environment['MHABIT_TEST_WEBDAV_DOCKER'] == '1';
  final fixture = WebDavAuthenticationFixture();

  HttpClient transport() {
    final context = SecurityContext(withTrustedRoots: true);
    context.setTrustedCertificates(fixture.certificate);
    return HttpClient(context: context);
  }

  Uri endpoint(String name, int port) => fixture.endpoint(name, port);

  WebDavStdClient authenticated(
    Uri root,
    Uri probe, {
    String password = 'regression-password',
  }) => WebDavStdClient.authenticated(
    client: transport(),
    authentication: WebDavAuthenticationConfig(
      scope: root,
      probeUri: probe,
      username: 'admin',
      password: password,
      discoveryTimeout: const Duration(seconds: 3),
    ),
  );

  group(
    'Compose authentication',
    () {
      setUpAll(() async {
        final previousOverrides = HttpOverrides.current;
        HttpOverrides.global = null;
        try {
          await fixture.start();
        } finally {
          HttpOverrides.global = previousOverrides;
        }
      });
      tearDownAll(fixture.stop);
      late HttpOverrides? previousOverrides;
      setUp(() {
        previousOverrides = HttpOverrides.current;
        HttpOverrides.global = null;
      });
      tearDown(() {
        HttpOverrides.global = previousOverrides;
      });
      for (final entry in {
        'basic': 18341,
        'mixed': 18342,
        'digest': 18343,
      }.entries) {
        registerWebDavSyncExtrasLiveTest(
          endpoint: endpoint(entry.key, entry.value).toString(),
          username: 'admin',
          password: 'regression-password',
          certificate: fixture.certificate,
          testName: '${entry.key}: full AppSync preserves unknown fields',
        );
      }
      test(
        'legacy SDK path reproduces the mixed-challenge exception',
        () async {
          final http = transport();
          http.authenticate = (url, scheme, realm) async => false;
          try {
            final request = await http.getUrl(endpoint('mixed', 18342));
            await expectLater(
              request.close(),
              throwsA(
                isA<HttpException>().having(
                  (e) => e.message,
                  'message',
                  contains('authentication challenge'),
                ),
              ),
            );
          } finally {
            http.close(force: true);
          }
        },
      );

      test(
        'mixed fixture sends exactly one combined challenge on 401',
        () async {
          final http = transport();
          try {
            final response = await (await http.getUrl(
              endpoint('mixed', 18342),
            )).close();
            expect(response.statusCode, 401);
            final challenges =
                response.headers[HttpHeaders.wwwAuthenticateHeader]!;
            expect(challenges, hasLength(1));
            expect(challenges.single, contains('Basic realm='));
            expect(challenges.single, contains(', Bearer resource_metadata='));
            await response.drain<void>();
          } finally {
            http.close(force: true);
          }
        },
      );

      for (final entry in {
        'basic': 18341,
        'mixed': 18342,
        'digest': 18343,
      }.entries) {
        test(
          '${entry.key}: MKCOL, PUT, PROPFIND, GET, overwrite, DELETE',
          () async {
            final root = endpoint(entry.key, entry.value);
            final directory = root.resolve(
              'auth-${DateTime.now().microsecondsSinceEpoch}/',
            );
            final file = directory.resolve('habit.json');
            final client = authenticated(root, directory);
            try {
              final mkdir = await (await client.dispatch(directory).createDir())
                  .close();
              expect(mkdir.response.statusCode, 201);
              await mkdir.response.drain<void>();
              for (final value in [1, 2]) {
                final payload = jsonEncode({'habit': '测试', 'record': value});
                final request = await client
                    .dispatch(file)
                    .create(data: payload);
                request.request.headers.contentType = ContentType.json;
                request.request.contentLength = utf8.encode(payload).length;
                final upload = await request.close();
                expect(upload.response.statusCode, isIn([201, 204]));
                expect(
                  upload.response.headers[HttpHeaders.wwwAuthenticateHeader],
                  isNull,
                );
                await upload.response.drain<void>();
                final download = await (await client.dispatch(file).get())
                    .close();
                expect(download.response.statusCode, 200);
                expect(
                  await utf8.decoder.bind(download.response).join(),
                  payload,
                );
              }
              final metadata =
                  await (await client
                          .dispatch(directory)
                          .findAllProps(depth: Depth.members))
                      .close();
              expect(metadata.response.statusCode, 207);
              expect(await metadata.parse(), isNotNull);
            } finally {
              try {
                final response =
                    await (await client.dispatch(directory).deleteDir())
                        .close();
                await response.response.drain<void>();
              } finally {
                client.close(force: true);
              }
            }
          },
        );

        test('${entry.key}: wrong password fails with 401', () async {
          final root = endpoint(entry.key, entry.value);
          final client = authenticated(root, root, password: 'wrong');
          try {
            if (entry.key == 'digest') {
              await expectLater(
                client.dispatch(root).get(),
                throwsA(
                  isA<WebDavAuthenticationError>().having(
                    (e) => e.statusCode,
                    'status',
                    401,
                  ),
                ),
              );
            } else {
              final response = await (await client.dispatch(root).get())
                  .close();
              expect(response.response.statusCode, 401);
              await response.response.drain<void>();
            }
          } finally {
            client.close(force: true);
          }
        });
      }
    },
    skip: !enabled
        ? 'Set MHABIT_TEST_WEBDAV_DOCKER=1 to run Docker integration tests.'
        : false,
  );
}
