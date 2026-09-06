import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/entries/app/navigation_chrome.dart';
import 'package:mhabit/entries/app/navigation_destination.dart';
import 'package:mhabit/routes/app_navigation_branch.dart';

void main() {
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

  test('keeps auxiliary chrome independent from route semantics', () {
    var selected = false;
    final chrome = AppNavigationAuxiliaryChrome(
      destination: AppNavigationDestinations.settings(label: 'Utility'),
      selected: true,
      onSelected: () => selected = true,
    );

    expect(chrome.destination.label, 'Utility');
    expect(chrome.selected, isTrue);
    chrome.onSelected();
    expect(selected, isTrue);
  });
}
