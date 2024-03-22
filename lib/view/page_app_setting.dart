// Copyright 2023 Fries_I23
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

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';

import '../common/consts.dart';
import '../common/enums.dart';
import '../common/utils.dart';
import '../component/helper.dart';
import '../component/widget.dart';
import '../db/db.dart';
import '../db/profile.dart';
import '../extension/context_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../logging/logger_stack.dart';
import '../model/app_reminder_config.dart';
import '../model/custom_date_format.dart';
import '../model/global.dart';
import '../provider/app_compact_ui_switcher.dart';
import '../provider/app_custom_date_format.dart';
import '../provider/app_developer.dart';
import '../provider/app_first_day.dart';
import '../provider/app_reminder.dart';
import '../provider/app_theme.dart';
import '../provider/habit_op_config.dart';
import '../provider/habit_summary.dart';
import '../provider/habits_file_exporter.dart';
import '../provider/habits_file_importer.dart';
import '../provider/habits_record_scroll_behavior.dart';
import '../reminders/notification_service.dart';
import 'common/_dialog.dart';
import 'common/_mixin.dart';
import 'common/_widget.dart';
import 'for_app_setting/_dialog.dart';
import 'for_app_setting/_widget.dart';
import 'page_app_about.dart' as app_about_view;

Future<void> naviToAppSettingPage({
  required BuildContext context,
  required HabitsRecordScrollBehaviorViewModel scrollBehavior,
  required HabitSummaryViewModel summary,
}) async {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: scrollBehavior),
          ChangeNotifierProvider.value(value: summary),
        ],
        child: const PageAppSetting(),
      ),
    ),
  );
}

class PageAppSetting extends StatelessWidget {
  const PageAppSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSettingView();
  }
}

class AppSettingView extends StatefulWidget {
  const AppSettingView({super.key});

  @override
  State<StatefulWidget> createState() => _AppSettingView();
}

class _AppSettingView extends State<AppSettingView>
    with XShare<AppSettingView> {
  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    super.initState();
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    super.dispose();
  }

  void _openCustomDateTimeFormatPickerDialog(BuildContext context) async {
    if (!mounted) return;
    final config = context.read<AppCustomDateYmdHmsConfigViewModel>();
    final result = await showCustomDateTimeFormatPickerDialog(
        context: context, config: config.config);

    if (!mounted || result == null) return;
    context.read<AppCustomDateYmdHmsConfigViewModel>().setNewConfig(result);
  }

  void _openAppFirtDaySelectDialog(BuildContext context) async {
    if (!mounted) return;
    final firstday = context.read<AppFirstDayViewModel>();
    final result = await showAppSettingFirstDaySelectDialog(
        context: context, firstDay: firstday.firstDay);

    if (!mounted || result == null) return;
    final firtdayvm = context.read<AppFirstDayViewModel>();
    firtdayvm.setNewFirstDay(result);
  }

  void _openClearAppCacheDialog(BuildContext context) async {
    if (!mounted) return;
    final result = await showAppSettingClearCacheDialog(context: context);
    if (!mounted || result != true) return;

    final resultList = await context.read<Global>().clearAllCache();
    if (!mounted) return;

    var hasSuss = false, hasFail = false;
    for (var result in resultList) {
      if (result) {
        hasSuss = true;
      } else {
        hasFail = true;
      }
    }

    final snackBar = BuildWidgetHelper().buildSnackBarWithDismiss(context,
        content: L10nBuilder(
      builder: (context, l10n) {
        final String? snackBarText;
        if (hasSuss && hasFail) {
          snackBarText = l10n?.appSetting_clearCache_snackBar_partSuccText;
        } else if (!hasFail) {
          snackBarText = l10n?.appSetting_clearCache_snackBar_succText;
        } else {
          snackBarText = l10n?.appSetting_clearCache_snackBar_failText;
        }
        return Text(snackBarText ?? "Clear cache done");
      },
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onDrageCalendarByPageTileChanged(bool value) {
    if (!mounted) return;
    final newBehavior = value
        ? HabitsRecordScrollBehavior.page
        : defaultHabitsRecordScrollBehavior;
    context
        .read<HabitsRecordScrollBehaviorViewModel>()
        .setScrollBehavior(newBehavior);
  }

  void _onCompactTileChanged(bool value) {
    if (!mounted) return;
    context.read<AppCompactUISwitcherViewModel>().setFlag(value);
  }

  void _onChangeRecordStatusSelected(UserAction action) {
    if (!mounted) return;
    context
        .read<HabitRecordOpConfigViewModel>()
        .setChangeRecordStatusAction(action);
  }

  void _onOpenRecordStatusDialogSelected(UserAction action) {
    if (!mounted) return;
    context
        .read<HabitRecordOpConfigViewModel>()
        .setOpenRecordStatusDialogAction(action);
  }

  void _onExportAllTilePressed(BuildContext context) async {
    if (!mounted) return;
    final confirmResult = await showExporterConfirmDialog(
      context: context,
      exportAll: true,
    );

    if (!mounted || confirmResult == null) return;
    final filePath = await context
        .read<HabitFileExporterViewModel>()
        .exportAllHabitsData(
          withRecords: confirmResult == ExporterConfirmResultType.withRecords,
        );
    if (!mounted || filePath == null) return;
    //TODO: add snackbar result
    shareXFiles([XFile(filePath)], context: context);
  }

  void _onImportAllTilePressed() async {
    FilePickerResult? result;
    if (!mounted) return;
    try {
      result = await FilePicker.platform.pickFiles();
    } on PlatformException catch (e) {
      appLog.load.error("$widget._onImportAllTilePressed",
          ex: ["Can't open file picker"],
          error: e,
          stackTrace: LoggerStackTrace.from(StackTrace.current));
      //TODO: add feedback
      return;
    }

    if (!mounted || result == null || result.files.single.path == null) return;
    final file = File(result.files.single.path!);

    String rawJsonData = '';
    try {
      rawJsonData = await file.readAsString();
    } on Exception catch (e) {
      //TODO: add feedback
      appLog.load.error("$widget._onImportAllTilePressed",
          ex: ["Can't read file", file],
          error: e,
          stackTrace: LoggerStackTrace.from(StackTrace.current));
      return;
    }

    if (!mounted || rawJsonData.isEmpty) return;
    final Map<String, Object?> jsonData = jsonDecode(rawJsonData);
    final habitsData = jsonData["habits"] as Iterable<Object?>? ?? const [];

    final fileImporter = context.read<HabitFileImporterViewModel>();
    final habitCount =
        fileImporter.importHabitsDataDryRun(habitsData).habitsCount;
    showAppSettingImportHabitsConfirmDialog(
      context: context,
      habitsData: habitsData,
      habitCount: habitCount,
      importer: context.read<HabitFileImporterViewModel>(),
    );
  }

  void _onResetConfigsTilePressed() async {
    final result = await showConfirmDialog(
      context: context,
      titleBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.appSetting_resetConfigDialog_titleText)
            : const Text("Reset configs?");
      },
      subtitleBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.appSetting_resetConfigDialog_subtitleText)
            : const SizedBox();
      },
      cancelTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.appSetting_resetConfigDialog_cancelText)
            : const Text("cancel");
      },
      confirmTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.appSetting_resetConfigDialog_confirmText)
            : const Text("confirm");
      },
    );

    if (result == null || !result) return;
    await Profile().clearAll();
    await NotificationService().cancelAppReminder();

    if (!mounted) return;
    final snackBar = BuildWidgetHelper().buildSnackBarWithDismiss(
      context,
      content: L10nBuilder(
        builder: (context, l10n) => l10n != null
            ? Text(l10n.appSetting_resetConfigSuccess_snackbarText)
            : const Text("reset application configs"),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _onDevelopModeSwitchTilePressed(bool value) async {
    if (!mounted) return;
    context.read<AppDeveloperViewModel>().switchDevelopMode(value);
  }

  void _onLogLevelChanged(LogLevel newLevel) async {
    if (!mounted) return;
    context.read<AppDeveloperViewModel>().loggingLevel = newLevel;
  }

  void _onDisplayDebugMenuSelectChanged(bool value) {
    if (!mounted) return;
    context.read<AppDeveloperViewModel>().switchDisplayDebugMenu(value);
  }

  void _onExportDBTilePressed(BuildContext context) async {
    if (!mounted) return;
    String dbPath = path.join(await getDatabasesPath(), appDBName);
    if (!mounted) return;
    shareXFiles([XFile(dbPath)], context: context);
  }

  void _onClearDBTilePressed(BuildContext context) async {
    if (!mounted) return;
    final result = await showAppSettingConfirmClearDBDiloag(context: context);

    if (!mounted) return;
    switch (result) {
      case AppSettingConfirmClearDBOp.confirm:
        break;
      case AppSettingConfirmClearDBOp.confirmWithExport:
        final filePath = await context
            .read<HabitFileExporterViewModel>()
            .exportAllHabitsData();
        final dbPath = path.join(await getDatabasesPath(), appDBName);
        if (!mounted) return;
        final result = await shareXFiles(
            [if (filePath != null) XFile(filePath), XFile(dbPath)],
            context: context);
        if (result.status == ShareResultStatus.success) {
          break;
        } else {
          if (!mounted) return;
          final snackBar = BuildWidgetHelper().buildSnackBarWithDismiss(
            context,
            content: const Text("clear failed, must saved backup first"),
          );
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(snackBar);
        }
        return;

      case AppSettingConfirmClearDBOp.cancel:
      default:
        return;
    }

    await DB().reInit();
    await NotificationService().cancelAllHabitReminders();
    if (!mounted) return;
    final snackBar = BuildWidgetHelper().buildSnackBarWithDismiss(
      context,
      content: const Text("clear database success"),
    );
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(snackBar);

    context
        .maybeRead<HabitSummaryViewModel>()
        ?.rockreloadDBToggleSwich(clearSnackBar: false);
  }

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> buildDisplaySubGroup(BuildContext context) sync* {
      yield GroupTitleListTile(
        title: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.appSetting_displaySubgroupText)
              : const Text("Display"),
        ),
      );
      yield Selector<AppFirstDayViewModel, int>(
        selector: (context, vm) => vm.firstDay,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, firstDay, child) => AppSettingFirstDayTile(
          firstDay: firstDay,
          onPressed: () => _openAppFirtDaySelectDialog(context),
        ),
      );
      yield Selector<AppCustomDateYmdHmsConfigViewModel,
          CustomDateYmdHmsConfig>(
        selector: (context, vm) => vm.config,
        shouldRebuild: (previous, next) => true,
        builder: (context, config, child) =>
            AppSettingDateDisplayFormatListTile(
          config: config,
          onPressed: () => _openCustomDateTimeFormatPickerDialog(context),
        ),
      );
      yield Selector<AppThemeViewModel, int>(
        selector: (context, vm) => vm.displayPageOccupyPrt,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, occupyPrt, child) => AppSettingCalbarOccupyTile(
          currentPercentage: occupyPrt,
          lessPercentage: normalizeAppCalendarBarOccupyPrt(
              appCalendarBarDefualtOccupyPrt - 20),
          morePercentage: normalizeAppCalendarBarOccupyPrt(
              appCalendarBarDefualtOccupyPrt + 20),
          normalPercentage: appCalendarBarDefualtOccupyPrt,
          onSelectionChanged: (int value) {
            context.read<AppThemeViewModel>().setNewDisplayPageOccupyPrt(value);
          },
        ),
      );
      yield Selector<AppCompactUISwitcherViewModel, bool>(
        selector: (context, vm) => vm.flag,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, flag, child) => L10nBuilder(
          builder: (context, l10n) => SwitchListTile(
            title: l10n != null
                ? Text(l10n.appSetting_compactUISwitcher_titleText)
                : const Text("Drag calendar by page"),
            subtitle: l10n != null
                ? Text(l10n.appSetting_compactUISwitcher_subtitleText)
                : null,
            onChanged: _onCompactTileChanged,
            value: flag,
          ),
        ),
      );
    }

    Iterable<Widget> buildOperationSubGroup(BuildContext context) sync* {
      yield GroupTitleListTile(
        title: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.appSetting_operationSubgroupText)
              : const Text("Operation"),
        ),
      );
      yield Selector<HabitsRecordScrollBehaviorViewModel,
          HabitsRecordScrollBehavior>(
        selector: (context, vm) => vm.scrollBehavior,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, scrollBehavior, child) => L10nBuilder(
          builder: (context, l10n) => SwitchListTile(
            title: l10n != null
                ? Text(l10n.appSetting_dragCalendarByPageTile_titleText)
                : const Text("Drag calendar by page"),
            subtitle: l10n != null
                ? Text(l10n.appSetting_dragCalendarByPageTile_subtitleText)
                : null,
            onChanged: _onDrageCalendarByPageTileChanged,
            value: scrollBehavior == HabitsRecordScrollBehavior.page,
          ),
        ),
      );
      yield Selector<HabitRecordOpConfigViewModel, UserAction>(
        selector: (context, vm) => vm.changeRecordStatus,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) => L10nBuilder(
          builder: (context, l10n) => LayoutBuilder(
            builder: (context, constraints) =>
                AppSettingDisplayRecordOperationTile(
              isLargeScreen:
                  constraints.maxWidth >= kHabitLargeScreenAdaptWidth,
              inputAction: value,
              title: l10n != null
                  ? Text(l10n.appSetting_changeRecordStatusOpTile_titleText)
                  : null,
              subtitle: l10n != null
                  ? Text(l10n.appSetting_changeRecordStatusOpTile_subtitleText)
                  : null,
              onSelected: _onChangeRecordStatusSelected,
            ),
          ),
        ),
      );
      yield Selector<HabitRecordOpConfigViewModel, UserAction>(
        selector: (context, vm) => vm.openRecordStatusDialog,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) => L10nBuilder(
          builder: (context, l10n) => LayoutBuilder(
            builder: (context, constraints) =>
                AppSettingDisplayRecordOperationTile(
              isLargeScreen:
                  constraints.maxWidth >= kHabitLargeScreenAdaptWidth,
              inputAction: value,
              title: l10n != null
                  ? Text(l10n.appSetting_openRecordStatusDialogOpTile_titleText)
                  : null,
              subtitle: l10n != null
                  ? Text(
                      l10n.appSetting_openRecordStatusDialogOpTile_subtitleText)
                  : null,
              onSelected: _onOpenRecordStatusDialogSelected,
            ),
          ),
        ),
      );
    }

    Iterable<Widget> buildReminderSubGroup(BuildContext context) sync* {
      yield GroupTitleListTile(
        title: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.appSetting_reminderSubgroupText)
              : const Text("Reminder"),
        ),
      );
      yield Selector<AppReminderViewModel, AppReminderConfig>(
        selector: (context, vm) => vm.reminder,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, reminder, child) => L10nBuilder(
          builder: (context, l10n) => AppSettingReminderTile(
            config: reminder,
            onSwitchButtonChanged: (value) => value
                ? context.read<AppReminderViewModel>().switchOn(l10n: l10n)
                : context.read<AppReminderViewModel>().switchOff(l10n: l10n),
            onTimePicked: (value) => context
                .read<AppReminderViewModel>()
                .switchToDaily(timeOfDay: value, l10n: l10n),
          ),
        ),
      );
    }

    Iterable<Widget> buildBackupAndRestoreSubGroup(BuildContext context) sync* {
      yield GroupTitleListTile(
        title: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.appSetting_backupAndRestoreSubgroupText)
              : const Text("Backup & restore"),
        ),
      );
      yield L10nBuilder(
        builder: (context, l10n) => ListTile(
          title: l10n != null
              ? Text(l10n.appSetting_export_titleText)
              : const Text("Export"),
          subtitle: l10n != null
              ? Text(l10n.appSetting_export_subtitleText)
              : const Text("Exported habits as JSON format, "
                  "This file can be import back"),
          onTap: () => _onExportAllTilePressed(context),
        ),
      );
      yield L10nBuilder(
        builder: (context, l10n) => ListTile(
          title: l10n != null
              ? Text(l10n.appSetting_import_titleText)
              : const Text("Import"),
          subtitle: l10n != null
              ? Text(l10n.appSetting_import_subtitleText)
              : const Text("Import habits from json file"),
          onTap: _onImportAllTilePressed,
        ),
      );
      yield L10nBuilder(
        builder: (context, l10n) => ListTile(
          title: l10n != null
              ? Text(l10n.appSetting_resetConfig_titleText)
              : const Text("Reset configs"),
          subtitle: l10n != null
              ? Text(l10n.appSetting_resetConfig_subtitleText)
              : const Text("Reset all configs to default"),
          onTap: _onResetConfigsTilePressed,
        ),
      );
    }

    Iterable<Widget> buildOthersSubGroup(BuildContext context) sync* {
      yield GroupTitleListTile(
        title: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.appSetting_otherSubgroupText)
              : const Text("Others"),
        ),
      );
      yield Selector<AppDeveloperViewModel, bool>(
        selector: (context, vm) => vm.isInDevelopMode,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) => SwitchListTile(
          title: L10nBuilder(
            builder: (context, l10n) => l10n != null
                ? Text(l10n.appSetting_developMode_titleText)
                : const Text("Develop mode"),
          ),
          onChanged: _onDevelopModeSwitchTilePressed,
          value: value,
        ),
      );
      yield ListTile(
        title: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.appSetting_clearCache_titleText)
              : const Text("Clear Cache"),
        ),
        onTap: () => _openClearAppCacheDialog(context),
      );
      yield ListTile(
        title: L10nBuilder(
          builder: (context, l10n) => l10n != null
              ? Text(l10n.appSetting_about_titleText)
              : const Text("About"),
        ),
        onTap: () => app_about_view.naviToAppAboutPage(context: context),
      );
    }

    Widget buildDevelopSubGroup(BuildContext context) {
      return Selector<AppDeveloperViewModel, Tuple3<bool, bool, LogLevel>>(
        selector: (context, vm) =>
            Tuple3(vm.isInDevelopMode, vm.displayDebugMenu, vm.loggingLevel),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) => AppSettingDevelopSubGroup(
          isInDevelopMode: value.item1,
          isDisplayDebugMenuSelect: value.item2,
          logLevel: value.item3,
          onLogLevelChanged: _onLogLevelChanged,
          onDisplayDebugMenuSelectChanged: _onDisplayDebugMenuSelectChanged,
          onExportDBTilePressed: _onExportDBTilePressed,
          onClearDBTilePressed: _onClearDBTilePressed,
        ),
      );
    }

    return ColorfulNavibar(
      child: Scaffold(
        appBar: AppBar(
          title: L10nBuilder(
            builder: (context, l10n) => l10n != null
                ? Text(l10n.appSetting_appbar_titleText)
                : const Text("Settings"),
          ),
          leading: const PageBackButton(reason: PageBackReason.back),
        ),
        body: EnhancedSafeArea.edgeToEdgeSafe(
          child: ListView(
            children: [
              ...buildDisplaySubGroup(context),
              ...buildOperationSubGroup(context),
              ...buildReminderSubGroup(context),
              ...buildBackupAndRestoreSubGroup(context),
              ...buildOthersSubGroup(context),
              buildDevelopSubGroup(context),
              const FixedPagePlaceHolder(),
            ],
          ),
        ),
      ),
    );
  }
}
