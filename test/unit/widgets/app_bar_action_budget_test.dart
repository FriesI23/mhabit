// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/widgets/app_bar_action_budget.dart';

({double primaryCapacity, int? maxPrimaryActions}) _values(
  AppBarActionBudget budget,
) => (
  primaryCapacity: budget.primaryCapacity,
  maxPrimaryActions: budget.maxPrimaryActions,
);

void main() {
  test('slots preserve page budgets and optional overflow reservation', () {
    expect(
      _values(
        AppBarActionBudget.slots(maxPrimaryActions: 1, reserveOverflow: false),
      ),
      (primaryCapacity: 48.0, maxPrimaryActions: 1),
    );
    expect(
      _values(
        AppBarActionBudget.slots(maxPrimaryActions: 2, reserveOverflow: true),
      ),
      (primaryCapacity: 144.0, maxPrimaryActions: 2),
    );
    expect(
      _values(
        AppBarActionBudget.slots(
          maxPrimaryActions: 3,
          reserveOverflow: true,
          additionalCapacity: 64,
        ),
      ),
      (primaryCapacity: 256.0, maxPrimaryActions: 3),
    );
  });

  test(
    'candidates preserve count limit while budgeting only occupied slots',
    () {
      for (final (count, overflow, capacity) in [
        (0, false, 0.0),
        (0, true, 48.0),
        (1, false, 48.0),
        (1, true, 96.0),
        (2, false, 96.0),
        (3, false, 144.0),
        (3, true, 144.0),
      ]) {
        expect(
          _values(
            AppBarActionBudget.candidates(
              primaryCount: count,
              maxPrimaryActions: 2,
              hasOverflow: overflow,
            ),
          ),
          (primaryCapacity: capacity, maxPrimaryActions: 2),
        );
      }
      expect(
        _values(
          AppBarActionBudget.candidates(
            primaryCount: 2,
            maxPrimaryActions: 0,
            hasOverflow: false,
          ),
        ),
        (primaryCapacity: 48.0, maxPrimaryActions: 0),
      );
    },
  );

  test('unlimited candidates and explicit capacity preserve null limit', () {
    expect(
      _values(
        AppBarActionBudget.candidates(
          primaryCount: 4,
          hasOverflow: false,
          slotExtent: 44,
        ),
      ),
      (primaryCapacity: 176.0, maxPrimaryActions: null),
    );
    expect(_values(const AppBarActionBudget.capacity(primaryCapacity: 137.5)), (
      primaryCapacity: 137.5,
      maxPrimaryActions: null,
    ));
  });

  test('rejects invalid counts and non-finite widths', () {
    expect(
      () => AppBarActionBudget.slots(
        maxPrimaryActions: -1,
        reserveOverflow: false,
      ),
      throwsAssertionError,
    );
    expect(
      () => AppBarActionBudget.candidates(primaryCount: -1, hasOverflow: false),
      throwsAssertionError,
    );
    for (final width in [-1.0, double.infinity, double.nan]) {
      expect(
        () => AppBarActionBudget.capacity(primaryCapacity: width),
        throwsAssertionError,
      );
      expect(
        () => AppBarActionBudget.slots(
          maxPrimaryActions: 1,
          reserveOverflow: false,
          slotExtent: width,
        ),
        throwsAssertionError,
      );
      expect(
        () => AppBarActionBudget.slots(
          maxPrimaryActions: 1,
          reserveOverflow: false,
          additionalCapacity: width,
        ),
        throwsAssertionError,
      );
    }
  });
}
