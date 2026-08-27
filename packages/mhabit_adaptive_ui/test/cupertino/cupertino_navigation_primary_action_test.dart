import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/src/cupertino/cupertino_navigation_primary_action.dart';

void main() {
  group('CupertinoNavigationPrimaryActionController', () {
    test('only the current owner can release the action', () {
      final controller = CupertinoNavigationPrimaryActionController();
      final previousOwner = Object();
      final currentOwner = Object();
      const previousAction = CupertinoNavigationPrimaryAction(
        id: 'previous',
        label: 'Previous',
        icon: SizedBox.shrink(),
        onPressed: null,
      );
      const currentAction = CupertinoNavigationPrimaryAction(
        id: 'current',
        label: 'Current',
        icon: SizedBox.shrink(),
        onPressed: null,
      );

      controller.report(previousOwner, previousAction);
      controller.report(currentOwner, currentAction);
      controller.release(previousOwner);
      expect(controller.value, same(currentAction));

      controller.release(currentOwner);
      expect(controller.value, isNull);
    });
  });
}
