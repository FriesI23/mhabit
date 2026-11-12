// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

/// The intended release channel, independent of the build flavor and installer.
enum AppDistribution {
  github('github'),
  googlePlay('google_play'),
  appStore('app_store'),
  microsoftStore('microsoft_store'),
  fdroid('fdroid'),
  flathub('flathub'),
  custom('custom');

  const AppDistribution(this.value);

  final String value;

  static AppDistribution parse(String value) {
    for (final distribution in values) {
      if (distribution.value == value) return distribution;
    }
    return github;
  }
}

/// The release channel supplied by the build's compilation environment.
const systemAppDistribution = String.fromEnvironment('APP_DISTRIBUTION');

/// The configured default used to initialize a support workflow.
final defaultAppDistribution = AppDistribution.parse(systemAppDistribution);
