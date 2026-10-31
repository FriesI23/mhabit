// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/app_info.dart';
import 'package:mhabit/extensions/app_info_extensions.dart';

class _DeviceInfo implements AppInfo {
  const _DeviceInfo({required this.isIPhoneDuo});

  @override
  final bool isIPhoneDuo;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'Duo layout requires both iOS and a recognized device',
    (_) async {
      expect(
        const _DeviceInfo(isIPhoneDuo: true).usesIPhoneDuoLayout,
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS,
      );
      expect(
        const _DeviceInfo(isIPhoneDuo: false).usesIPhoneDuoLayout,
        isFalse,
      );
    },
    variant: TargetPlatformVariant.all(),
  );
}
