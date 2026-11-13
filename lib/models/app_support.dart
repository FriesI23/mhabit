// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import '../common/distribution.dart';

/// Support destinations and release-channel routing, independent of UI hosts.
///
/// Store links always use the published app identity. Choosing a channel does
/// not infer an installer or change the identity of the running application.
enum AppSupportAction {
  /// Opens the project page from the GitHub Star button.
  githubStar,

  /// Opens the published Android app's Google Play page.
  googlePlay(
    'https://play.google.com/store/apps/details?id=io.github.friesi23.mhabit',
  ),

  /// Opens the published app's App Store review page.
  appStore('https://apps.apple.com/app/id6744886469?action=write-review'),

  /// Opens the published app's Microsoft Store review page.
  microsoftStore('ms-windows-store://review/?ProductId=9NG22PL73NGZ'),

  /// Opens the Flathub page, where users can favorite the app.
  flathub('https://flathub.org/apps/io.github.friesi23.mhabit'),

  /// Opens the source repository from the participation card.
  sourceCode,

  /// Opens the configured issue tracker.
  feedback,

  /// Presents the configured donation methods.
  donate;

  const AppSupportAction([this._storeUrl]);

  final String? _storeUrl;

  /// The channel's review or public-favorite action, alongside GitHub.
  static AppSupportAction forDistribution({
    required AppDistribution distribution,
  }) => switch (distribution) {
    AppDistribution.googlePlay => googlePlay,
    AppDistribution.appStore => appStore,
    AppDistribution.microsoftStore => microsoftStore,
    AppDistribution.flathub => flathub,
    AppDistribution.github ||
    AppDistribution.fdroid ||
    AppDistribution.custom => githubStar,
  };

  /// A store with a user review or public-favorite support mechanism.
  bool get isStore => _storeUrl != null;

  /// System-handled store link, or null for project and donation actions.
  Uri? get storeUri => _storeUrl == null ? null : Uri.parse(_storeUrl);
}

/// Reminder timing and dismissal saved together in the user's profile.
typedef AppSupportReminderHistory = ({
  DateTime minimumDate,
  int launches,
  bool closed,
});
