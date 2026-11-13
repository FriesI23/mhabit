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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';

void main() {
  testWidgets(
    'developer settings omit UI style and Sidebar appearance',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppSettingDevelopSubGroup(isInDevelopMode: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppSettingUiStyleTile), findsNothing);
      expect(find.byType(AppSettingAppleSidebarStyleTile), findsNothing);
      expect(tester.takeException(), isNull);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    }),
  );
}
