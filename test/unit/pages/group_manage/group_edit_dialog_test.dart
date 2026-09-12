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
import 'package:mhabit/pages/common/_widgets/group_edit_form.dart';
import 'package:mhabit/pages/group_manage/_widgets/group_edit_dialog.dart';
import 'package:mhabit/providers/app_ui/custom_color_history.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final presentation in AdaptiveModalPresentation.values) {
      testWidgets('group edit forces Material actions from ${style.name} '
          'in ${presentation.name}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(800, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        GroupEditFormResult? result;
        var completed = false;
        await tester.pumpWidget(
          AdaptiveStyleScope(
            override: style,
            child: ChangeNotifierProvider(
              create: (_) => CustomColorHistoryViewModel(),
              child: MaterialApp(
                home: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      result = await showGroupEditDialog(
                        context: context,
                        presentationOverride: presentation,
                      );
                      completed = true;
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(AdaptiveModal), findsOneWidget);
        expect(
          tester
              .widget<AdaptiveModal>(find.byType(AdaptiveModal))
              .leadingAction,
          isNull,
        );
        expect(find.text('Create Group'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('adaptive-modal-implied-close')),
          findsNothing,
        );

        final modalWidth = tester
            .getSize(find.byKey(const ValueKey('adaptive-modal-constraints')))
            .width;
        expect(modalWidth, switch (presentation) {
          AdaptiveModalPresentation.sheet => 640,
          AdaptiveModalPresentation.dialog => 560,
        });

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(completed, isTrue);
        expect(result, isNull);
      });
    }
  }
}
