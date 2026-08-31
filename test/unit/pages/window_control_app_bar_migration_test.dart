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

Finder get _adaptiveAppBarActions => find.byWidgetPredicate(
  (widget) => widget is AdaptiveAppBarActions,
  description: 'AdaptiveAppBarActions with any payload type',
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
    final controller = TextEditingController(text: 'Habit');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        HabitEditAppBar(
          name: 'Habit',
          color: const HabitColor.builtIn(HabitColorType.cc1),
          controller: controller,
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
    expect(find.byType(AdaptiveEditableSliverAppBar), findsOneWidget);
    expect(find.byType(AdaptiveSliverAppBar), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(CupertinoTextField), findsNothing);
    expect(_adaptiveAppBarActions, findsOneWidget);
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.close,
    );
    expect(appBar.pinned, isTrue);
    expect(appBar.floating, isFalse);
    expect(appBar.snap, isFalse);
    expect(appBar.automaticallyImplyLeading, isFalse);
    expect(appBar.flexibleSpace, isNotNull);

    await tester.tap(find.text('Save'));
    expect(saved, isTrue);
  });

  testWidgets('HabitEditAppBar Apple uses fixed bar and inset name field', (
    tester,
  ) async {
    var saved = false;
    var changedName = '';
    final controller = TextEditingController(text: 'Habit');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        HabitEditAppBar(
          name: 'Habit',
          color: const HabitColor.builtIn(HabitColorType.cc1),
          controller: controller,
          autofocus: false,
          isAppbarPinned: false,
          showInFullscreenDialog: false,
          onNameChanged: (value) => changedName = value,
          onSaveButtonPressed: () => saved = true,
        ),
        platform: TargetPlatform.iOS,
      ),
    );

    expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    expect(find.byType(WindowControlSliverAppBar), findsNothing);
    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title-placeholder')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title')),
      findsNothing,
    );
    final nameField = tester.widget<CupertinoTextField>(
      find.byKey(const ValueKey('editable-app-bar-apple-field')),
    );
    expect(nameField.clearButtonMode, OverlayVisibilityMode.editing);
    expect(nameField.textInputAction, TextInputAction.done);
    expect(nameField.decoration?.borderRadius, BorderRadius.circular(10));
    final nameFieldPadding = tester.widget<SliverPadding>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SliverPadding &&
            widget.padding ==
                const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
      ),
    );
    expect(
      nameFieldPadding.padding,
      const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
    );
    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.back,
    );
    expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
    final saveButton = find.ancestor(
      of: find.text('Save'),
      matching: find.byType(CupertinoButton),
    );
    expect(saveButton, findsOneWidget);
    expect(tester.getSize(saveButton).height, greaterThanOrEqualTo(44));

    await tester.enterText(
      find.byKey(const ValueKey('editable-app-bar-apple-field')),
      'Updated',
    );
    expect(changedName, 'Updated');

    await tester.tap(saveButton);
    expect(saved, isTrue);
  });

  testWidgets('HabitEditAppBar Apple fullscreen dialog uses close', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Habit');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        HabitEditAppBar(
          name: 'Habit',
          color: const HabitColor.builtIn(HabitColorType.cc1),
          controller: controller,
          autofocus: false,
          isAppbarPinned: true,
          showInFullscreenDialog: true,
        ),
        platform: TargetPlatform.iOS,
      ),
    );

    expect(
      tester.widget<AdaptiveBackButton>(find.byType(AdaptiveBackButton)).type,
      AdaptiveBackButtonType.close,
    );
    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('editable-app-bar-apple-title-placeholder')),
      findsNothing,
    );
  });

  testWidgets('HabitEditAppBar hides and disables Save semantics', (
    tester,
  ) async {
    var saveCount = 0;
    final controller = TextEditingController(text: 'Habit');
    addTearDown(controller.dispose);
    Widget buildHost({required bool showSaveButton}) => _host(
      HabitEditAppBar(
        name: 'Habit',
        color: const HabitColor.builtIn(HabitColorType.cc1),
        controller: controller,
        autofocus: false,
        isAppbarPinned: false,
        showInFullscreenDialog: false,
        showSaveButton: showSaveButton,
        onSaveButtonPressed: () => saveCount += 1,
      ),
    );
    await tester.pumpWidget(buildHost(showSaveButton: true));

    await tester.pumpWidget(buildHost(showSaveButton: false));
    await tester.pump(const Duration(milliseconds: 100));
    final saveVisibility = find.byKey(
      const ValueKey('habit-edit.save-visibility'),
    );
    expect(
      find.ancestor(
        of: _adaptiveAppBarActions,
        matching: find.byType(AnimatedOpacity),
      ),
      findsNothing,
    );
    final transitioningOpacity = tester.widget<AnimatedOpacity>(saveVisibility);
    expect(transitioningOpacity.opacity, 0);
    final fadeTransition = find.descendant(
      of: find.byWidget(transitioningOpacity),
      matching: find.byType(FadeTransition),
    );
    expect(
      tester.widget<FadeTransition>(fadeTransition).opacity.value,
      inExclusiveRange(0, 1),
    );
    await tester.pumpAndSettle();

    final opacity = tester.widget<AnimatedOpacity>(saveVisibility);
    expect(opacity.opacity, 0);
    expect(opacity.duration, const Duration(milliseconds: 200));
    final semanticsExclusion = tester.widget<ExcludeSemantics>(
      find.descendant(
        of: saveVisibility,
        matching: find.byType(ExcludeSemantics),
      ),
    );
    expect(semanticsExclusion.excluding, isTrue);
    final saveButton = tester.widget<TextButton>(find.byType(TextButton).last);
    expect(saveButton.onPressed, isNull);

    await tester.tap(find.text('Save'), warnIfMissed: false);
    expect(saveCount, 0);
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
