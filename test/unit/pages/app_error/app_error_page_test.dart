// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/app_error/page.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

Widget _host({required TargetPlatform platform, required bool showCloseBtn}) {
  return MaterialApp(
    theme: ThemeData(platform: platform),
    home: AppErrorPage(
      details: FlutterErrorDetails(
        exception: StateError('test exception'),
        stack: StackTrace.fromString('test stack'),
      ),
      showCloseBtn: showCloseBtn,
    ),
  );
}

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('uses adaptive error chrome on $platform', (tester) async {
      await tester.pumpWidget(_host(platform: platform, showCloseBtn: true));

      expect(find.byType(AdaptiveSliverAppBar), findsOneWidget);
      expect(find.byType(AdaptiveBackButton), findsOneWidget);
      expect(find.text('Unhandled Exception'), findsOneWidget);
      expect(find.text('Bad state: test exception'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      final close = tester.widget<AdaptiveBackButton>(
        find.byType(AdaptiveBackButton),
      );
      expect(close.type, AdaptiveBackButtonType.close);
    });
  }

  testWidgets('omits the close control when the entry disallows it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(platform: TargetPlatform.macOS, showCloseBtn: false),
    );

    expect(find.byType(AdaptiveBackButton), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
