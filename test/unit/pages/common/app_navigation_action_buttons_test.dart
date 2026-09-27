// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/common/widgets.dart';
import 'package:mhabit/theme/color.dart';

void main() {
  for (final testCase
      in <
        ({
          TargetPlatform platform,
          IconData settings,
          IconData light,
          IconData dark,
          IconData system,
          Type buttonType,
        })
      >[
        (
          platform: TargetPlatform.android,
          settings: Icons.settings,
          light: Icons.light_mode_rounded,
          dark: Icons.dark_mode_rounded,
          system: Icons.hdr_auto_rounded,
          buttonType: IconButton,
        ),
        (
          platform: TargetPlatform.iOS,
          settings: CupertinoIcons.settings_solid,
          light: CupertinoIcons.sun_max_fill,
          dark: CupertinoIcons.moon_fill,
          system: CupertinoIcons.circle_lefthalf_fill,
          buttonType: CupertinoButton,
        ),
      ]) {
    testWidgets('${testCase.platform} uses matching navigation action icons', (
      tester,
    ) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: testCase.platform),
          home: Scaffold(
            body: Row(
              children: [
                AppSettingsButton(onPressed: () => pressed = true),
                const AppSettingsIcon(selected: false),
                const AppThemeModeIcon(themeType: AppThemeType.light),
                const AppThemeModeIcon(themeType: AppThemeType.dark),
                const AppThemeModeIcon(themeType: AppThemeType.followSystem),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(testCase.settings), findsOneWidget);
      expect(
        find.byIcon(
          testCase.platform == TargetPlatform.iOS
              ? CupertinoIcons.settings
              : Icons.settings_outlined,
        ),
        findsOneWidget,
      );
      expect(find.byIcon(testCase.light), findsOneWidget);
      expect(find.byIcon(testCase.dark), findsOneWidget);
      expect(find.byIcon(testCase.system), findsOneWidget);
      expect(find.byType(testCase.buttonType), findsOneWidget);

      await tester.tap(find.byType(AppSettingsButton));
      expect(pressed, isTrue);
    });
  }
}
