// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_sync_options.dart';
import 'package:mhabit/models/app_sync_server.dart';
import 'package:mhabit/models/app_sync_server_form.dart';
import 'package:mhabit/pages/app_sync_server_editor/_providers/app_sync_server_form.dart';
import 'package:mhabit/pages/app_sync_server_editor/page.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/support/global.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

final class _FakeAppSyncSettingsAccess extends ChangeNotifier
    implements AppSyncSettingsAccess {
  @override
  bool get enabled => true;

  @override
  AppSyncFetchInterval get fetchInterval => AppSyncFetchInterval.minute30;

  @override
  AppSyncServer? get serverConfig => null;

  @override
  Future<String?> readPassword({String? identity}) async => null;

  @override
  Future<String> readPasswordDisplayText() async => '';

  @override
  Future<bool> deleteServerConfig() async => false;

  @override
  Future<bool> saveServerConfigForm(
    AppSyncServerForm form, {
    bool resetStatus = false,
  }) async => false;

  @override
  Future<void> setFetchInterval(
    AppSyncFetchInterval value, {
    bool listen = true,
  }) async {}

  @override
  Future<void> setSyncSwitch(bool value, {bool listen = true}) async {}
}

Widget _host({required AdaptiveStyle style}) {
  final global = Global()..switchDevelopMode(false);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppDeveloperViewModel>(
        create: (_) => AppDeveloperViewModel(global: global),
      ),
      ChangeNotifierProvider<_FakeAppSyncSettingsAccess>(
        create: (_) => _FakeAppSyncSettingsAccess(),
      ),
      ListenableProvider<AppSyncSettingsAccess>(
        create: (context) => context.read<_FakeAppSyncSettingsAccess>(),
        dispose: (_, _) {},
      ),
    ],
    child: AdaptiveStyleScope(
      override: style,
      child: const MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        home: _Launcher(),
      ),
    ),
  );
}

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Launcher')));
}

void main() {
  for (final style in AdaptiveStyle.values) {
    for (final presentation in AdaptiveModalPresentation.values) {
      testWidgets('sync editor forces Material from ${style.name} in '
          '${presentation.name}', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(800, 800);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        AppSyncServerEditorResult? result;
        var completed = false;
        await tester.pumpWidget(_host(style: style));

        final launcherContext = tester.element(find.text('Launcher'));
        final future = naviToAppSyncServerEditorDialog(
          context: launcherContext,
          presentationOverride: presentation,
        );
        future.then((value) {
          result = value;
          completed = true;
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        final modal = find.byType(AdaptiveModal);
        expect(modal, findsOneWidget);
        expect(AdaptiveStyle.of(tester.element(modal)), AdaptiveStyle.material);
        expect(find.text('New Sync Server'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('adaptive-modal-implied-close')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('adaptive-modal-bottom-actions')),
          findsNothing,
        );
        expect(find.byType(Dialog), switch (presentation) {
          AdaptiveModalPresentation.dialog => findsOneWidget,
          AdaptiveModalPresentation.sheet => findsNothing,
        });
        expect(find.byType(BottomSheet), switch (presentation) {
          AdaptiveModalPresentation.dialog => findsNothing,
          AdaptiveModalPresentation.sheet => findsOneWidget,
        });

        await tester.tap(find.text('Cancel'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(completed, isTrue);
        expect(result, isNull);
      });
    }
  }

  testWidgets('system Back confirms before closing an edited sync editor', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var completed = false;
    await tester.pumpWidget(_host(style: AdaptiveStyle.apple));

    final future = naviToAppSyncServerEditorDialog(
      context: tester.element(find.text('Launcher')),
      presentationOverride: AdaptiveModalPresentation.dialog,
    );
    future.then((_) => completed = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final modalContext = tester.element(find.byType(AdaptiveModal));
    modalContext.read<AppSyncServerFormViewModel>().webdav!.path = '/changed';
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Unsaved Changes'), findsOneWidget);
    expect(completed, isFalse);

    await tester.tap(find.text('Exit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(completed, isTrue);
  });

  testWidgets('sync sheet hides its drag handle and cannot be dragged closed', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var completed = false;
    await tester.pumpWidget(_host(style: AdaptiveStyle.apple));

    final future = naviToAppSyncServerEditorDialog(
      context: tester.element(find.text('Launcher')),
    );
    future.then((_) => completed = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final modalContext = tester.element(find.byType(AdaptiveModal));
    modalContext.read<AppSyncServerFormViewModel>().webdav!.path = '/changed';
    await tester.pump();

    expect(find.byType(DraggableScrollableSheet), findsNothing);
    expect(
      find.byKey(const ValueKey('adaptive-material-sheet-drag-handle')),
      findsNothing,
    );

    final drag = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('adaptive-modal-app-bar'))),
    );
    await drag.moveBy(const Offset(0, 600));
    await drag.up();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Unsaved Changes'), findsNothing);
    expect(completed, isFalse);
  });

  testWidgets('sync editor returns the validated form on Save', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    AppSyncServerEditorResult? result;
    await tester.pumpWidget(_host(style: AdaptiveStyle.material));

    final future = naviToAppSyncServerEditorDialog(
      context: tester.element(find.text('Launcher')),
      presentationOverride: AdaptiveModalPresentation.dialog,
    );
    future.then((value) => result = value);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final modalContext = tester.element(find.byType(AdaptiveModal));
    modalContext.read<AppSyncServerFormViewModel>().webdav!.path = '/sync';
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(result?.op, AppSyncServerEditorResultOp.update);
    expect((result?.form as WebDavSyncServerForm?)?.path, '/sync');
  });

  testWidgets('sync editor returns Delete after confirmation', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    AppSyncServerEditorResult? result;
    await tester.pumpWidget(_host(style: AdaptiveStyle.material));

    final future = naviToAppSyncServerEditorDialog(
      context: tester.element(find.text('Launcher')),
      serverConfig: AppSyncServer.newServer(AppSyncServerType.webdav),
      presentationOverride: AdaptiveModalPresentation.dialog,
    );
    future.then((value) => result = value);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Confirm Delete'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(result?.op, AppSyncServerEditorResultOp.delete);
    expect(result?.form, isNull);
  });
}
