import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/l10n/localizations.dart';
import 'package:mhabit/models/app_sync_tasks.dart';
import 'package:mhabit/pages/app_settings/_widgets/app_setting_sync_failed_tile.dart';
import 'package:mhabit/pages/common/_widgets/sync_now_tile.dart';
import 'package:mhabit/providers/workflow/app_sync.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

class _Sync extends ChangeNotifier
    implements AppSyncTriggerAccess, AppSyncStatusSource {
  @override
  bool canStartSync = true;
  @override
  AppSyncStatusSnapshot? syncStatus;
  int starts = 0;
  int cancels = 0;
  void emit(
    AppSyncTaskStatus status, {
    AppSyncTaskResult? result,
    num? percentage,
    String sessionId = 'session',
  }) {
    syncStatus = AppSyncStatusSnapshot(
      id: 'task',
      sessionId: sessionId,
      status: status,
      startTime: null,
      endedTime: null,
      result: result,
      percentage: percentage,
    );
    notifyListeners();
  }

  @override
  Future<void> startSync({Duration? initWait}) async {
    expect(initWait, kAppSyncDelayDuration1);
    starts++;
  }

  @override
  void cancelSync() => cancels++;
  @override
  void delayedStartTaskOnce({Duration delay = kAppSyncOnceDelay}) {}
}

void main() {
  for (final platform in [
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ]) {
    for (final direction in TextDirection.values) {
      testWidgets('sync state actions and failure lifecycle $platform $direction', (
        tester,
      ) async {
        final sync = _Sync();
        addTearDown(sync.dispose);
        ExpansibleController controller() => tester
            .widget<AdaptiveExpansionTile>(
              find.byType(AdaptiveExpansionTile).first,
            )
            .controller!;
        tester.view.physicalSize = const Size(320, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ListenableProvider<AppSyncTriggerAccess>.value(value: sync),
              ListenableProvider<AppSyncStatusSource>.value(value: sync),
            ],
            child: MaterialApp(
              theme: ThemeData(platform: platform),
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(2)),
                child: Directionality(textDirection: direction, child: child!),
              ),
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: AdaptiveListSection(
                    children: [AppSyncNowTile(), AppSettingSyncFailedTile()],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester
            .pumpAndSettle(); // Idle must not leave a hidden busy animation.
        final action = find.byKey(const ValueKey('sync-action'));
        final l10n = L10n.of(tester.element(action))!;
        await tester.tap(action);
        expect(sync.starts, 1);
        sync.canStartSync = false;
        sync.emit(AppSyncTaskStatus.idle);
        await tester.pumpAndSettle();
        expect(tester.widget<AdaptiveIconButton>(action).onPressed, isNull);
        sync.emit(AppSyncTaskStatus.running, percentage: .25);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.widget<AdaptiveIconButton>(action).onPressed, isNotNull);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          closeTo(.25, .001),
        );
        await tester.tap(action);
        expect(sync.cancels, 1);
        sync.emit(AppSyncTaskStatus.cancelling);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.widget<AdaptiveIconButton>(action).onPressed, isNull);
        sync.emit(
          AppSyncTaskStatus.cancelled,
          result: const BasicAppSyncTaskResult.cancelled(),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveExpansionTile), findsNothing);
        sync.emit(
          AppSyncTaskStatus.completed,
          result: const BasicAppSyncTaskResult.error(
            error: 'First failure\nSecond detail',
          ),
        );
        await tester.pumpAndSettle();
        expect(controller().isExpanded, false);
        expect(
          find
              .text(l10n.appSync_failedTile_errorText('First failure'))
              .hitTestable(),
          findsOneWidget,
        );
        expect(
          find.textContaining('Second detail').hitTestable(),
          findsNothing,
        );
        controller().expand();
        await tester.pumpAndSettle();
        expect(
          find.text(l10n.appSync_failedTile_errorText('First failure')),
          findsNothing,
        );
        expect(
          find.textContaining('Second detail').hitTestable(),
          findsOneWidget,
        );
        controller().collapse();
        await tester.pumpAndSettle();
        // Progress/status updates retaining the same result do not reopen a user collapse.
        sync.emit(
          AppSyncTaskStatus.completed,
          result: sync.syncStatus!.result,
          percentage: .5,
        );
        await tester.pumpAndSettle();
        expect(controller().isExpanded, false);
        controller().expand();
        await tester.pumpAndSettle();
        sync.emit(
          AppSyncTaskStatus.completed,
          result: sync.syncStatus!.result,
          percentage: .75,
        );
        await tester.pumpAndSettle();
        expect(controller().isExpanded, true);
        sync.emit(
          AppSyncTaskStatus.completed,
          result: const WebDavAppSyncTaskResult.error(error: 'WebDAV failure'),
        );
        await tester.pumpAndSettle();
        expect(controller().isExpanded, false);
        expect(
          find.textContaining('WebDAV failure').hitTestable(),
          findsOneWidget,
        );
        sync.emit(
          AppSyncTaskStatus.completed,
          result: WebDavAppSyncTaskResult.multi(
            results: {},
            groupResults: {
              WebDavAppSyncGroupInfo(
                configUUID: 'config',
                uuid: 'group',
                status: WebDavAppSyncInfoStatus.local,
              ): const WebDavAppSyncTaskResult.error(
                error: 'Group failure',
              ),
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(controller().isExpanded, false);
        expect(
          find
              .text(l10n.appSync_failedTile_errorText('Group failure'))
              .hitTestable(),
          findsOneWidget,
        );
        controller().expand();
        await tester.pumpAndSettle();
        final category = find.byType(AdaptiveExpansionTile).at(1);
        await tester.tap(
          find.descendant(of: category, matching: find.byType(Text)).first,
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Group failure').hitTestable(),
          findsOneWidget,
        );
        // A new session with the same result starts with fresh expansion storage.
        sync.emit(
          AppSyncTaskStatus.completed,
          result: sync.syncStatus!.result,
          sessionId: 'next-session',
        );
        await tester.pump();
        expect(controller().isExpanded, false);
        controller().expand();
        await tester.pumpAndSettle();
        expect(
          find.textContaining('[0] Group failure').hitTestable(),
          findsNothing,
        );
        await tester.tap(
          find.descendant(of: category, matching: find.byType(Text)).first,
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('[0] Group failure').hitTestable(),
          findsOneWidget,
        );
        sync.emit(
          AppSyncTaskStatus.completed,
          result: const BasicAppSyncTaskResult.success(),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AdaptiveExpansionTile), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        expect(tester.takeException(), isNull);
      });
    }
  }
}
