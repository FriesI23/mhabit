import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/routes/app_navigation_branch.dart';
import 'package:mhabit/routes/app_router.dart';

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

  test('maps app navigation branches to their root routes', () {
    expect(AppNavigationBranch.habits.rootRoute, AppRoute.habits);
    expect(AppNavigationBranch.habits.rootRouteName, AppRoute.habits.name);
    expect(AppNavigationBranch.today.rootRoute, AppRoute.today);
    expect(AppNavigationBranch.today.rootRouteName, AppRoute.today.name);
  });
}
