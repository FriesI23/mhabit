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
import 'package:mhabit/models/app_adaptive_style_mode.dart';
import 'package:mhabit/pages/app_settings/widgets.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/storage/profile/handlers.dart';
import 'package:mhabit/storage/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(ProfileViewModel, AppDeveloperViewModel)> _loadViewModel() async {
  SharedPreferences.setMockInitialValues({});
  final profile = ProfileViewModel([AdaptiveStyleOverrideProfileHandler.new]);
  await profile.init();
  final viewModel = AppDeveloperViewModel(global: Global(), profile: profile);
  return (profile, viewModel);
}

Widget _host(AppDeveloperViewModel viewModel) =>
    ChangeNotifierProvider<AppDeveloperViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Consumer<AppDeveloperViewModel>(
              builder: (context, value, child) => AppSettingDevelopSubGroup(
                isInDevelopMode: value.isInDevelopMode,
                isDisplayDebugMenuSelect: value.displayDebugMenu,
                adaptiveStyleMode: value.adaptiveStyleMode,
                textDirectionOverride: value.textDirectionOverride,
                onDisplayDebugMenuSelectChanged: value.switchDisplayDebugMenu,
                onAdaptiveStyleModeChanged: value.setAdaptiveStyleMode,
                onTextDirectionOverrideChanged: value.setTextDirectionOverride,
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('style control is visible only while develop mode is on', (
    tester,
  ) async {
    final (profile, viewModel) = await _loadViewModel();
    addTearDown(profile.dispose);
    addTearDown(viewModel.dispose);

    viewModel.switchDevelopMode(false);
    await tester.pumpWidget(_host(viewModel));
    await tester.pumpAndSettle();

    final control = find.byKey(const ValueKey('developer-ui-style-control'));
    expect(control, findsOneWidget);
    expect(control.hitTestable(), findsNothing);

    viewModel.switchDevelopMode(true);
    await tester.pumpAndSettle();
    expect(control.hitTestable(), findsOneWidget);

    viewModel.switchDevelopMode(false);
    await tester.pumpAndSettle();
    expect(control.hitTestable(), findsNothing);
  });

  testWidgets('three-state selection writes through the view model', (
    tester,
  ) async {
    final (profile, viewModel) = await _loadViewModel();
    addTearDown(profile.dispose);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(_host(viewModel));
    await tester.pumpAndSettle();

    final control = find.byKey(const ValueKey('developer-ui-style-control'));
    expect(find.byType(MenuAnchor), findsNWidgets(2));
    expect(
      tester
          .widgetList<MenuAnchor>(find.byType(MenuAnchor))
          .every((anchor) => anchor.animated),
      isTrue,
    );
    final tile = find.ancestor(of: control, matching: find.byType(ListTile));
    expect(
      tester.getCenter(control).dx,
      greaterThan(tester.getCenter(tile).dx),
    );
    expect(
      find.descendant(of: control, matching: find.text('Automatic')),
      findsOneWidget,
    );

    await tester.tap(control);
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsNWidgets(3));
    await tester.tap(find.text('Material'));
    await tester.pumpAndSettle();
    expect(viewModel.adaptiveStyleMode, AppAdaptiveStyleMode.material);

    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(viewModel.adaptiveStyleMode, AppAdaptiveStyleMode.apple);
  });

  testWidgets('text direction control switches three in-memory states', (
    tester,
  ) async {
    final (profile, viewModel) = await _loadViewModel();
    addTearDown(profile.dispose);
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(_host(viewModel));
    await tester.pumpAndSettle();

    final control = find.byKey(
      const ValueKey('developer-text-direction-control'),
    );
    expect(
      find.descendant(of: control, matching: find.text('Auto')),
      findsOneWidget,
    );

    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.text('LTR'));
    await tester.pumpAndSettle();
    expect(viewModel.textDirectionOverride, TextDirection.ltr);

    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.text('RTL'));
    await tester.pumpAndSettle();
    expect(viewModel.textDirectionOverride, TextDirection.rtl);

    await tester.tap(control);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Auto'));
    await tester.pumpAndSettle();
    expect(viewModel.textDirectionOverride, isNull);
  });
}
