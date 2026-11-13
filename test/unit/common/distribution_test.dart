// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/distribution.dart';

void main() {
  const channels = {
    'github': AppDistribution.github,
    'google_play': AppDistribution.googlePlay,
    'app_store': AppDistribution.appStore,
    'microsoft_store': AppDistribution.microsoftStore,
    'fdroid': AppDistribution.fdroid,
    'flathub': AppDistribution.flathub,
    'custom': AppDistribution.custom,
  };

  test('reads the channel passed to the actual compiler', () {
    const expectedSystemValue = String.fromEnvironment(
      'TEST_SYSTEM_APP_DISTRIBUTION',
    );
    const expected = String.fromEnvironment(
      'TEST_DISTRIBUTION',
      defaultValue: 'github',
    );
    expect(systemAppDistribution, expectedSystemValue);
    expect(defaultAppDistribution.value, expected);
  });

  test('recognizes explicit release channels', () {
    for (final entry in channels.entries) {
      expect(AppDistribution.parse(entry.key), entry.value);
      expect(entry.value.value, entry.key);
    }
  });

  test('missing and unrecognized values keep generic support', () {
    for (final value in ['', 'unknown', 'store', 'f_store', 'GOOGLE_PLAY']) {
      expect(AppDistribution.parse(value), AppDistribution.github);
    }
  });
}
