// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import '../common/distribution.dart';

/// Support destinations and release-channel routing, independent of UI hosts.
///
/// Store links always use the published app identity. Choosing a channel does
/// not infer an installer or change the identity of the running application.
enum AppSupportAction {
  support,
  googlePlay(
    'https://play.google.com/store/apps/details?id=io.github.friesi23.mhabit',
  ),
  appStore('https://apps.apple.com/app/id6744886469?action=write-review'),
  microsoftStore('ms-windows-store://review/?ProductId=9NG22PL73NGZ'),
  flathub('https://flathub.org/apps/io.github.friesi23.mhabit'),
  sourceCode,
  feedback,
  donate;

  const AppSupportAction([this._storeUrl]);

  final String? _storeUrl;

  /// The channel's review or public-favorite action, alongside GitHub.
  static AppSupportAction supportFor({required AppDistribution distribution}) =>
      switch (distribution) {
        AppDistribution.googlePlay => googlePlay,
        AppDistribution.appStore => appStore,
        AppDistribution.microsoftStore => microsoftStore,
        AppDistribution.flathub => flathub,
        AppDistribution.github ||
        AppDistribution.fdroid ||
        AppDistribution.custom => support,
      };

  /// A store with a user review or public-favorite support mechanism.
  bool get isStore => _storeUrl != null;

  /// System-handled store link, or null for project and donation actions.
  Uri? get storeUri => _storeUrl == null ? null : Uri.parse(_storeUrl);
}
