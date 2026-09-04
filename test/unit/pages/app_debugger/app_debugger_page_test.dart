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

import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/app_debugger/page.dart';
import 'package:mhabit/providers/app_ui/app_debugger.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

Future<void> _pumpPage(
  WidgetTester tester, {
  required TargetPlatform platform,
}) async {
  final viewModel = AppDebuggerViewModel();
  addTearDown(viewModel.dispose);
  await tester.pumpWidget(
    ChangeNotifierProvider<AppDebuggerViewModel>.value(
      value: viewModel,
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: const AppDebuggerPage(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('uses the Material adaptive app bar and keeps page content', (
    tester,
  ) async {
    await _pumpPage(tester, platform: TargetPlatform.android);

    expect(find.byType(AdaptiveAppBar), findsOneWidget);
    expect(find.byType(WindowControlAppBar), findsOneWidget);
    expect(find.text('Debug Info'), findsOneWidget);
    expect(find.text('Logging Information'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(AdaptiveAppBarActions), findsNothing);
    expect(
      tester.widget<AdaptiveAppBar>(find.byType(AdaptiveAppBar)).toolbarHeight,
      64.0,
    );
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );
    expect(
      tester
          .widget<AdaptiveAppBar>(find.byType(AdaptiveAppBar))
          .automaticallyImplyLeading,
      isFalse,
    );
  });

  testWidgets('uses the Apple adaptive app bar and keeps the share FAB', (
    tester,
  ) async {
    await _pumpPage(tester, platform: TargetPlatform.iOS);

    expect(find.byType(AdaptiveAppBar), findsOneWidget);
    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.text('Debug Info'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(AdaptiveAppBarActions), findsNothing);
    expect(
      tester.widget<AdaptiveAppBar>(find.byType(AdaptiveAppBar)).toolbarHeight,
      44.0,
    );
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );
  });
}
