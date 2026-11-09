# Live WebDAV authentication checks

The package's normal `make check` reuses its native Dart HTTP server. It covers
Basic, Basic + Bearer, Digest and failure/lifecycle cases without Docker.

For application-level acceptance, use the published package dependency and run
from this app repository with Docker Desktop running and `openssl` available:

```sh
.flutter/bin/flutter pub get
MHABIT_TEST_WEBDAV_DOCKER=1 CI=true .flutter/bin/flutter test --no-pub \
  test/harness/webdav_server/webdav_authentication_integration_test.dart
```

No setup script or manual container startup is required. The test group's
`setUpAll` creates a test CA, starts Compose and waits for readiness;
`tearDownAll` captures logs and removes that invocation's containers and volumes,
including after test failures. The normal Flutter test suite discovers these
tests, but Docker checks are skipped unless the flag is set. Forced termination
of the test process can prevent teardown.
Timed-out fixture commands are stopped before cleanup starts; each readiness
attempt also bounds connection setup and response-body draining.

The fixture extends the existing Bytemark WebDAV service and adds Basic, mixed
Basic/Bearer and Digest TLS entrypoints on loopback ports 18341-18343. Override
`WEBDAV_BASIC_PORT`, `WEBDAV_MIXED_PORT` and `WEBDAV_DIGEST_PORT` if needed. Do not
run instances concurrently on the same ports. Compose project names contain the
test process ID so cleanup does not target another invocation's project.

The suite verifies the legacy SDK failure control, exact combined challenge,
file operations and wrong passwords. It also runs the existing AppSync round
trip on all three endpoints: create a missing root, download Habit/Group/Record
data, edit locally, upload and verify unknown fields remain intact.

Certificates are generated under `test/harness/webdav_server/authentication/tls/`
and ignored. Tests trust the dedicated CA without modifying the system trust
store. Logs, image digests and response-header evidence are written to
`build/test-results/issue690/`. Local protocol and real WebDAV acceptance do not
constitute authenticated Fastmail account acceptance.

`webdav_sync_extras_live_test.dart` can still run against a separately managed
server using `MHABIT_TEST_WEBDAV_URL`, `MHABIT_TEST_WEBDAV_USER`,
`MHABIT_TEST_WEBDAV_PASSWORD` and optional `MHABIT_TEST_WEBDAV_CA`.
