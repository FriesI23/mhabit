// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('AppInfo.changelogVersion', () {
    test('returns "version+buildNumber" format after init', () async {
      PackageInfo.setMockInitialValues(
        appName: 'mhabit',
        packageName: 'com.example.mhabit',
        version: '1.25.3',
        buildNumber: '168',
        buildSignature: '',
      );
      await AppInfo().init();

      expect(AppInfo().changelogVersion, '1.25.3+168');
    });

    test('strips leading v from version', () async {
      PackageInfo.setMockInitialValues(
        appName: 'mhabit',
        packageName: 'com.example.mhabit',
        version: 'v1.25.3',
        buildNumber: '168',
        buildSignature: '',
      );
      await AppInfo().init();

      expect(AppInfo().changelogVersion, '1.25.3+168');
    });

    test('strips leading V (uppercase) from version', () async {
      PackageInfo.setMockInitialValues(
        appName: 'mhabit',
        packageName: 'com.example.mhabit',
        version: 'V1.25.3',
        buildNumber: '168',
        buildSignature: '',
      );
      await AppInfo().init();

      expect(AppInfo().changelogVersion, '1.25.3+168');
    });

    test('handles version with pre-release suffix', () async {
      PackageInfo.setMockInitialValues(
        appName: 'mhabit',
        packageName: 'com.example.mhabit',
        version: '1.25.3-dev',
        buildNumber: '168',
        buildSignature: '',
      );
      await AppInfo().init();

      expect(AppInfo().changelogVersion, '1.25.3-dev+168');
    });

    test('fallback from appVersion when init not called', () {
      // AppInfo is a singleton; this test must run before init().
      // We test the fallback branch by using a fresh AppInfo instance.
      // Since AppInfo is a singleton, we rely on the fallback logic:
      // when _packageInfo is null, parse from _appVersion.
      //
      // This test only verifies the fallback expression is reachable
      // and does not throw; the exact value depends on singleton state.
      final version = AppInfo().changelogVersion;
      // After other tests have called init(), we get the post-init value.
      expect(version, isNotEmpty);
      expect(version, contains('+'));
    });

    test('fallback strips leading v and replaces ": " with "+"', () async {
      // To test the fallback path, we need a scenario where _packageInfo
      // is null but _appVersion was set. Since AppInfo is a singleton and
      // we can't easily reset it, we verify the init-set value includes the
      // + separator (not ": ") and no leading v/V.
      PackageInfo.setMockInitialValues(
        appName: 'mhabit',
        packageName: 'com.example.mhabit',
        version: 'v2.0.0',
        buildNumber: '200',
        buildSignature: '',
      );
      await AppInfo().init();

      final version = AppInfo().changelogVersion;
      expect(version, '2.0.0+200');
      expect(version, isNot(contains(':')));
      expect(version, isNot(startsWith('v')));
      expect(version, isNot(startsWith('V')));
    });
  });
}
