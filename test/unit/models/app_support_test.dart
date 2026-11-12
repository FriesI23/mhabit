// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/common/distribution.dart';
import 'package:mhabit/models/app_support.dart';

void main() {
  for (final (distribution, target) in [
    (AppDistribution.github, AppSupportAction.support),
    (AppDistribution.googlePlay, AppSupportAction.googlePlay),
    (AppDistribution.appStore, AppSupportAction.appStore),
    (AppDistribution.microsoftStore, AppSupportAction.microsoftStore),
    (AppDistribution.fdroid, AppSupportAction.support),
    (AppDistribution.flathub, AppSupportAction.flathub),
    (AppDistribution.custom, AppSupportAction.support),
  ]) {
    test('$distribution selects its additional support destination', () {
      expect(AppSupportAction.supportFor(distribution: distribution), target);
      if (distribution == AppDistribution.fdroid) {
        expect(target.isStore, isFalse);
        expect(target.storeUri, isNull);
      }
    });
  }

  test('Google Play links to the published Android package', () {
    const target = AppSupportAction.googlePlay;
    expect(target.isStore, isTrue);
    expect(target.storeUri!.scheme, 'https');
    expect(target.storeUri!.host, 'play.google.com');
    expect(target.storeUri!.path, '/store/apps/details');
    expect(target.storeUri!.queryParameters, {
      'id': 'io.github.friesi23.mhabit',
    });
  });

  test('Apple requests the shared iOS and macOS write-review page', () {
    const target = AppSupportAction.appStore;
    expect(target.isStore, isTrue);
    expect(target.storeUri!.scheme, 'https');
    expect(target.storeUri!.host, 'apps.apple.com');
    expect(target.storeUri!.path, '/app/id6744886469');
    expect(target.storeUri!.queryParameters, {'action': 'write-review'});
  });

  test('Microsoft Store links to the published product review experience', () {
    const target = AppSupportAction.microsoftStore;
    expect(target.isStore, isTrue);
    expect(target.storeUri!.scheme, 'ms-windows-store');
    expect(target.storeUri!.host, 'review');
    expect(target.storeUri!.queryParameters, {'ProductId': '9NG22PL73NGZ'});
  });

  test(
    'Flathub opens its page for a manual favorite, without a review action',
    () {
      const target = AppSupportAction.flathub;
      expect(target.isStore, isTrue);
      expect(target.storeUri!.scheme, 'https');
      expect(target.storeUri!.host, 'flathub.org');
      expect(target.storeUri!.path, '/apps/io.github.friesi23.mhabit');
      expect(target.storeUri!.queryParameters, isEmpty);
    },
  );

  test('project and donation actions do not contain store destinations', () {
    for (final target in [
      AppSupportAction.support,
      AppSupportAction.sourceCode,
      AppSupportAction.feedback,
      AppSupportAction.donate,
    ]) {
      expect(target.isStore, isFalse);
      expect(target.storeUri, isNull);
    }
  });
}
