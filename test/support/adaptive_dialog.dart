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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Finder get adaptiveDialogFinder => find.byWidgetPredicate(
  (widget) =>
      widget is MaterialAdaptiveDialog || widget is CupertinoAdaptiveDialog,
  description: 'Material or Cupertino adaptive dialog renderer',
);

List<AdaptiveDialogAction> adaptiveDialogActions(WidgetTester tester) =>
    switch (tester.widget(adaptiveDialogFinder)) {
      MaterialAdaptiveDialog(:final actions) => actions,
      CupertinoAdaptiveDialog(:final actions) => actions,
      _ => throw StateError('Expected an adaptive dialog renderer'),
    };
