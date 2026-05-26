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

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/provider.dart';
import 'package:provider/provider.dart';

final class _Value1 {
  final int value;

  const _Value1(this.value);
}

final class _Value2 {
  final int value;

  const _Value2(this.value);
}

final class _TrackingNotifier extends ChangeNotifier {
  int? firstValue;
  int? secondValue;
  int disposeCount = 0;

  void update(int first, int second) {
    firstValue = first;
    secondValue = second;
  }

  @override
  void dispose() {
    disposeCount += 1;
    super.dispose();
  }
}

void main() {
  testWidgets(
    'ViewModelProxyProvider2 with explicit create owns notifier lifecycle',
    (tester) async {
      _TrackingNotifier? notifier;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<_Value1>.value(value: const _Value1(1)),
            Provider<_Value2>.value(value: const _Value2(2)),
            ViewModelProxyProvider2<_Value1, _Value2, _TrackingNotifier>(
              create: (context) => notifier = _TrackingNotifier(),
              update: (context, value1, value2, previous) =>
                  previous..update(value1.value, value2.value),
            ),
          ],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                final vm = context.watch<_TrackingNotifier>();
                return Text('${vm.firstValue}-${vm.secondValue}');
              },
            ),
          ),
        ),
      );

      expect(find.text('1-2'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());

      expect(notifier?.disposeCount, 1);
    },
  );
}
