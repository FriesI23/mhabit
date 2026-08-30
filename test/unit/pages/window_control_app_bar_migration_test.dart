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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/extensions/adaptive_style_extensions.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/models/habit_color_type.dart';
import 'package:mhabit/pages/habit_detail/_widgets/habit_detail_appbar.dart';
import 'package:mhabit/pages/habit_edit/_widgets/habit_edit_app_bar.dart';
import 'package:mhabit/pages/habits_status_changer/_widgets/habit_status_changer_appbar.dart';
import 'package:mhabit/widgets/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host(Widget appBar, {TargetPlatform? platform}) => MaterialApp(
  theme: platform == null ? null : ThemeData(platform: platform),
  home: Scaffold(body: CustomScrollView(slivers: [appBar])),
);

void main() {
  testWidgets('HabitDetailAppBar preserves its sliver configuration', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        HabitDetailAppBar(
          title: const Text('Detail'),
          actionBuilder: (_) => const SizedBox(key: ValueKey('detail-action')),
        ),
      ),
    );

    final adaptive = tester.widget<AdaptiveSliverAppBar>(
      find.byType(AdaptiveSliverAppBar),
    );
    final wrapper = tester.widget<WindowControlSliverAppBar>(
      find.byType(WindowControlSliverAppBar),
    );
    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(wrapper.pinned, isTrue);
    expect(wrapper.leading, isA<PageBackButton>());
    expect(find.byType(AdaptiveBackButton), findsOneWidget);
    expect(wrapper.actions, hasLength(1));
    expect(adaptive.height, AppAdaptiveStyle.materialToolbarHeight);
    expect(find.text('Detail'), findsOneWidget);
    expect(find.byKey(const ValueKey('detail-action')), findsOneWidget);
    expect(appBar.pinned, isTrue);
    expect(appBar.floating, isFalse);
    expect(appBar.snap, isFalse);
    expect(appBar.toolbarHeight, AppAdaptiveStyle.materialToolbarHeight);
  });

  testWidgets(
    'HabitDetailAppBar uses the fixed Apple toolbar and back button',
    (tester) async {
      await tester.pumpWidget(
        _host(
          HabitDetailAppBar(
            title: const Text('Detail'),
            actionBuilder: (_) =>
                const SizedBox(key: ValueKey('detail-action')),
          ),
          platform: TargetPlatform.iOS,
        ),
      );

      expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
      expect(find.byType(AdaptiveBackButton), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(
        tester.getSize(find.byType(CupertinoButton)).height,
        greaterThanOrEqualTo(44),
      );
      expect(find.byKey(const ValueKey('detail-action')), findsOneWidget);
      expect(
        tester.getSize(find.byType(CupertinoNavigationBar)).height,
        AppAdaptiveStyle.appleToolbarHeight,
      );
    },
  );

  testWidgets('HabitEditAppBar preserves large app-bar behavior and actions', (
    tester,
  ) async {
    var saved = false;
    await tester.pumpWidget(
      _host(
        HabitEditAppBar(
          name: 'Habit',
          color: const HabitColor.builtIn(HabitColorType.cc1),
          scrolledUnderElevation: 3,
          autofocus: false,
          isAppbarPinned: false,
          showInFullscreenDialog: true,
          onSaveButtonPressed: () => saved = true,
        ),
      ),
    );

    final wrapper = tester.widget<WindowControlSliverAppBar>(
      find.byType(WindowControlSliverAppBar),
    );
    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(wrapper.pinned, isTrue);
    expect(wrapper.automaticallyImplyLeading, isFalse);
    expect(wrapper.scrolledUnderElevation, 3);
    expect(wrapper.flexibleSpace, isNotNull);
    expect(wrapper.leading, isA<PageBackButton>());
    expect(appBar.pinned, isTrue);
    expect(appBar.automaticallyImplyLeading, isFalse);
    expect(appBar.flexibleSpace, isNotNull);

    await tester.tap(find.text('Save'));
    expect(saved, isTrue);
  });

  testWidgets(
    'HabitStatusChangerAppbar preserves toolbar and bottom behavior',
    (tester) async {
      var closed = false;
      await tester.pumpWidget(
        _host(
          HabitStatusChangerAppbar(
            title: const Text('Batch'),
            bottomWidget: const SizedBox(key: ValueKey('batch-bottom')),
            onCloseButtonPressed: () => closed = true,
          ),
        ),
      );

      final wrapper = tester.widget<WindowControlSliverAppBar>(
        find.byType(WindowControlSliverAppBar),
      );
      final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(wrapper.pinned, isTrue);
      expect(wrapper.floating, isTrue);
      expect(wrapper.automaticallyImplyLeading, isFalse);
      expect(wrapper.bottom?.preferredSize.height, kToolbarHeight);
      expect(find.text('Batch'), findsOneWidget);
      expect(find.byKey(const ValueKey('batch-bottom')), findsOneWidget);
      expect(appBar.pinned, isTrue);
      expect(appBar.floating, isTrue);

      await tester.tap(find.byType(PageBackButton));
      expect(closed, isTrue);
    },
  );
}
