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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit/pages/common/widgets.dart';

void main() {
  testWidgets('LoadErrorPlaceholder shows fallback content and handles retry', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoadErrorPlaceholder(onRetry: () => retried = true),
        ),
      ),
    );

    expect(find.byType(NotFoundImage), findsOneWidget);
    expect(find.text('Load data failed'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));

    expect(retried, isTrue);
  });

  testWidgets(
    'LoadErrorPlaceholder respects custom message without retry button',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadErrorPlaceholder(message: Text('Custom load failure')),
          ),
        ),
      );

      expect(find.byType(NotFoundImage), findsOneWidget);
      expect(find.text('Custom load failure'), findsOneWidget);
      expect(find.text('Load data failed'), findsNothing);
      expect(find.text('Try Again'), findsNothing);
    },
  );
}
