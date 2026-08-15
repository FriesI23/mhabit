import 'package:flutter_test/flutter_test.dart';

import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('AdaptiveNavVisibilityController', () {
    test('notifies when visibility changes', () {
      final controller = AdaptiveNavVisibilityController();
      var notified = 0;
      controller.addListener(() => notified++);

      controller.hide();
      expect(controller.value, isFalse);
      expect(notified, 1);

      controller.show();
      expect(controller.value, isTrue);
      expect(notified, 2);
    });

    test('does not notify when visibility is unchanged', () {
      final controller = AdaptiveNavVisibilityController();
      var notified = 0;
      controller.addListener(() => notified++);

      controller.show();
      expect(notified, 0);

      controller.hide();
      controller.hide();
      expect(controller.value, isFalse);
      expect(notified, 1);
    });
  });

  group('AdaptiveScrollWishController', () {
    test('notifies when the wish changes', () {
      final controller = AdaptiveScrollWishController();
      var notified = 0;
      controller.addListener(() => notified++);

      controller.report(false);
      expect(controller.value, isFalse);
      expect(notified, 1);
    });

    test('does not notify when the wish is unchanged', () {
      final controller = AdaptiveScrollWishController();
      var notified = 0;
      controller.addListener(() => notified++);

      controller.report(true);
      expect(notified, 0);
    });

    test('reset restores the visible wish', () {
      final controller = AdaptiveScrollWishController();
      controller.report(false);
      var notified = 0;
      controller.addListener(() => notified++);

      controller.reset();
      expect(controller.value, isTrue);
      expect(notified, 1);

      controller.reset();
      expect(notified, 1);
    });
  });
}
