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

import 'package:flutter/cupertino.dart' show CupertinoSliverNavigationBar;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/pages/habits_display/_providers/habit_summary.dart';
import 'package:mhabit/pages/habits_display/widgets.dart';
import 'package:provider/provider.dart';

Widget _searchBarHost(HabitSummaryViewModel vm) => ChangeNotifierProvider.value(
  value: vm,
  child: const MaterialApp(
    restorationScopeId: 'app',
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    home: Scaffold(body: CustomScrollView(slivers: [SliverSearchTopAppBar()])),
  ),
);

final class _TestHabitSummaryViewModel extends HabitSummaryViewModel {
  @override
  Future<void> resortData({bool listen = true}) async {
    if (listen) notifyListeners();
  }
}

void main() {
  testWidgets('selection app bar stays Material on iOS', (tester) async {
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: const CustomScrollView(slivers: [SliverEditTopAppBar()]),
        ),
      ),
    );

    expect(find.byType(SliverAppBar), findsOneWidget);
    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
  });

  testWidgets('search adapter synchronizes input and external VM exit', (
    tester,
  ) async {
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));

    await tester.tap(find.byKey(const ValueKey('activate-search')));
    await tester.pump();
    expect(vm.isInSearchMode, isTrue);

    await tester.enterText(find.byType(SearchBar), 'alpha');
    await tester.pump();
    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(vm.searchOptions.keyword, 'alpha');
    expect(searchBar.controller?.text, 'alpha');
    expect(searchBar.focusNode?.hasFocus, isTrue);

    vm.exitSearchMode();
    await tester.pumpAndSettle();
    final updated = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(updated.controller?.text, isEmpty);
    expect(updated.focusNode?.hasFocus, isFalse);
  });

  testWidgets('tap outside exits only an empty changed search', (tester) async {
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));

    await tester.enterText(find.byType(SearchBar), 'alpha');
    await tester.enterText(find.byType(SearchBar), '');
    await tester.pump();
    expect(vm.isInSearchMode, isTrue);

    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    searchBar.onTapOutside!(const PointerDownEvent());
    await tester.pump();
    expect(vm.isInSearchMode, isFalse);
  });

  testWidgets('breakpoint rebuild preserves controller, focus and filters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vm = _TestHabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));

    await tester.enterText(find.byType(SearchBar), 'kept');
    vm.onSearchOngoingChanged(true);
    await tester.pump();
    final before = tester.widget<SearchBar>(find.byType(SearchBar));

    tester.view.physicalSize = const Size(800, 600);
    await tester.pump();
    final after = tester.widget<SearchBar>(find.byType(SearchBar));

    expect(after.controller, same(before.controller));
    expect(after.focusNode, same(before.focusNode));
    expect(after.controller?.text, 'kept');
    expect(after.focusNode?.hasFocus, isTrue);
    expect(vm.searchOptions.activated, isTrue);
  });

  testWidgets('restoration keeps controller and VM keyword consistent', (
    tester,
  ) async {
    final vm = HabitSummaryViewModel();
    addTearDown(vm.dispose);
    await tester.pumpWidget(_searchBarHost(vm));
    await tester.enterText(find.byType(SearchBar), 'restored');
    await tester.pump();

    final restorationData = await tester.getRestorationData();
    vm.exitSearchMode(listen: false);
    await tester.restoreFrom(restorationData);
    await tester.pump();

    final searchBar = tester.widget<SearchBar>(find.byType(SearchBar));
    expect(searchBar.controller?.text, 'restored');
    expect(vm.searchOptions.keyword, 'restored');
  });
}
