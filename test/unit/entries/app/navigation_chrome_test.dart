import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/app/navigation_chrome.dart';

void main() {
  test('maps navigation branches through explicit router indexes', () {
    expect(
      AppNavigationBranch.fromNavigationIndex(0),
      AppNavigationBranch.habits,
    );
    expect(
      AppNavigationBranch.fromNavigationIndex(1),
      AppNavigationBranch.today,
    );
    expect(
      () => AppNavigationBranch.fromNavigationIndex(2),
      throwsArgumentError,
    );
  });

  test('keeps chrome state independent for each navigation branch', () {
    final controller = AppNavigationChromeController();
    addTearDown(controller.dispose);

    expect(
      controller.chromeFor(AppNavigationBranch.habits).primaryAction,
      AppNavigationPrimaryAction.createHabit,
    );
    expect(
      controller.chromeFor(AppNavigationBranch.today),
      const AppNavigationBranchChrome(),
    );

    controller.setContextualChromeSuppressed(AppNavigationBranch.habits, true);

    expect(
      controller
          .chromeFor(AppNavigationBranch.habits)
          .contextualChromeSuppressed,
      isTrue,
    );
    expect(
      controller
          .chromeFor(AppNavigationBranch.today)
          .contextualChromeSuppressed,
      isFalse,
    );
  });

  test('releases a primary action only from its registered callback', () {
    final controller = AppNavigationChromeController();
    addTearDown(controller.dispose);
    var invocationCount = 0;
    void action() => invocationCount += 1;
    void otherAction() {}

    controller.registerPrimaryAction(AppNavigationBranch.habits, action);
    controller.unregisterPrimaryAction(AppNavigationBranch.habits, otherAction);
    controller.invokePrimaryAction(AppNavigationBranch.habits);
    expect(invocationCount, 1);

    controller.unregisterPrimaryAction(AppNavigationBranch.habits, action);
    controller.invokePrimaryAction(AppNavigationBranch.habits);
    expect(invocationCount, 1);
  });
}
