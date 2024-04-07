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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../common/consts.dart';
import '../common/rules.dart';
import '../common/types.dart';
import '../component/widget.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../model/habit_daily_goal.dart';
import '../model/habit_display.dart';
import '../model/habit_form.dart';
import '../model/habit_freq.dart';
import '../model/habit_reminder.dart';
import '../persistent/local/handler/habit.dart';
import '../provider/app_caches.dart';
import '../provider/app_developer.dart';
import '../provider/app_first_day.dart';
import '../provider/habit_form.dart';
import '../reminders/notification_channel.dart';
import '../reminders/notification_id_range.dart' as notifyid;
import '../reminders/notification_service.dart';
import '_debug.dart';
import 'common/_dialog.dart';
import 'common/_widget.dart';
import 'for_habit_edit/_dialogs.dart';
import 'for_habit_edit/_widget.dart';

const double _kCommonEvalation = 1.0;

Future<HabitDBCell?> naviToHabitEidtPage({
  required BuildContext context,
  required HabitForm initForm,
  bool? naviWithFullscreenDialog,
}) async {
  return Navigator.of(context).push<HabitDBCell>(
    MaterialPageRoute(
      fullscreenDialog: naviWithFullscreenDialog ?? true,
      builder: (context) => PageHabitEdit(
        initForm: initForm,
        showInFullscreenDialog: false,
      ),
    ),
  );
}

/// Depend Providers
/// - Required for builder:
///   - [AppFirstDayViewModel]
///   - [AppDeveloperViewModel]
/// - Required for callback:
///   - [NotificationChannelData]
///   - [AppCachesViewModel]
class PageHabitEdit extends StatelessWidget {
  final HabitForm? initForm;
  final bool showInFullscreenDialog;

  const PageHabitEdit({
    super.key,
    this.initForm,
    this.showInFullscreenDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return PageProviders(
        initForm: initForm,
        child: HabitEditView(
            initForm: initForm,
            showInFullscreenDialog: showInFullscreenDialog));
  }
}

class HabitEditView extends StatefulWidget {
  final HabitForm? initForm;
  final bool showInFullscreenDialog;

  const HabitEditView({
    super.key,
    this.initForm,
    this.showInFullscreenDialog = false,
  });

  @override
  State<StatefulWidget> createState() => _HabitEditView();
}

class _HabitEditView extends State<HabitEditView> {
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

  void _openColorPickerDialog(
      BuildContext context, HabitColorType colorType) async {
    final result = await showHabitColorPickerDialog(
        context: context, colorType: colorType);
    if (result == null || !mounted) return;
    context.read<HabitFormViewModel>().colorType = result;
  }

  void _openHabitTypePickerDialog() async {
    if (!mounted) return;
    final result = await showHabitTypSelectDialog(
        context: context,
        habitType: context.read<HabitFormViewModel>().habitType);
    if (result == null || !mounted) return;
    context.read<HabitFormViewModel>().habitType = result;
  }

  void _openFrequencyPickerDialog(
      BuildContext context, HabitFrequency frequency) async {
    final result = await showHabitFrequencyPickerDialog(
        context: context, frequency: frequency);
    appLog.navi.info("$runtimeType._openFrequencyPickerDialog", ex: [result]);
    if (result == null || !mounted) return;
    context.read<HabitFormViewModel>().frequency = result;
  }

  void _openDatePickerDialog(BuildContext context, DateTime startDate,
      HabitColorType colorType) async {
    final result = await showHabitDatePickerDialog(
        context: context, date: startDate, colorType: colorType);
    appLog.navi.info("$runtimeType._openDatePickerDialog", ex: [result]);
    if (result == null || !mounted) return;
    context.read<HabitFormViewModel>().startDate =
        HabitStartDate.dateTime(result);
  }

  void _openTargetDaysPickerDialog(BuildContext context, int targetDays) async {
    final result = await showHabitTargetDaysPickerDialog(
      context: context,
      targetDays: targetDays,
      initialCustomTargetDays:
          context.read<AppCachesViewModel>().habitEditTargetDaysInputFill,
    );
    if (result == null || !mounted) return;
    context.read<HabitFormViewModel>().targetDays = result.targetDays;
    if (result.isCustomDaysType) {
      context
          .read<AppCachesViewModel>()
          .updateHabitEditTargetDaysInputFill(result.targetDays);
    }
  }

  void _openReminderTypePickerDialog(
      BuildContext context, HabitReminder? reminder) async {
    if (!mounted) return;
    final colorType = context.read<HabitFormViewModel>().colorType;
    final result = await showHabitReminderTypePickerDialog(
      context: context,
      reminder: reminder ?? HabitReminder.dailyMidnight,
      colorType: colorType,
    );
    if (!mounted || result == null) return;
    context.read<HabitFormViewModel>().reminder = context
        .read<HabitFormViewModel>()
        .reminder
        ?.copyWith(type: result.type, extra: result.extra);
  }

  void _openTimerPickerDialog(
      BuildContext context, HabitReminder? reminder) async {
    await NotificationService().requestPermissions();
    if (!mounted) return;
    final result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (!mounted || result == null) return;
    var newReminder = (context.read<HabitFormViewModel>().reminder ??
            HabitReminder.dailyMidnight)
        .copyWith(time: result);
    context.read<HabitFormViewModel>().reminder = newReminder;
  }

  void _onReminderTimeTileCancelButtonPressed() async {
    if (!mounted) return;
    final result = await showConfirmDialog(
      context: context,
      titleBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitEdit_reminder_cancelDialogTitle)
            : const Text('Confirm');
      },
      subtitleBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitEdit_reminder_cancelDialogSubtitle)
            : const Text('');
      },
      confirmTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitEdit_reminder_cancelDialogConfirm)
            : const Text('confirm');
      },
      cancelTextBuilder: (context) {
        final l10n = L10n.of(context);
        return l10n != null
            ? Text(l10n.habitEdit_reminder_cancelDialogCancel)
            : const Text('cancel');
      },
    );
    if (!mounted || result != true) return;
    context.read<HabitFormViewModel>().reminder = null;
  }

  void _onSaveButtonPressed() async {
    HabitFormViewModel formvm;
    if (!mounted) return;
    formvm = context.read<HabitFormViewModel>();
    if (!formvm.canSaveHabit()) return;
    final HabitDBCell? result = await formvm.saveHabit();
    if (!mounted) return;
    // add reminder
    final details = context.read<NotificationChannelData>().habitReminder;
    if (result != null) {
      final habit = await formvm.loadSingleHabitSummaryFromDB(result.uuid!,
          firstDay: context.read<AppFirstDayViewModel>().firstDay);
      if (habit != null && habit.reminder != null) {
        NotificationService().regrHabitReminder(
          id: notifyid.getHabitReminderId(habit.id),
          uuid: habit.uuid,
          name: habit.name,
          reminder: habit.reminder!,
          quest: habit.reminderQuest,
          lastUntrackDate: habit.getFirstUnTrackedDate(),
          details: details,
        );
      } else if (result.id != null) {
        NotificationService().cancelHabitReminder(
          id: notifyid.getHabitReminderId(result.id!),
        );
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  Widget _buildDebugInfo(BuildContext context) {
    return Consumer<HabitFormViewModel>(
      builder: (context, value, child) => ListTile(
        leading: Icon(Icons.error, color: Theme.of(context).colorScheme.error),
        isThreeLine: true,
        title: const Text('DEBUG'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${value.name}"),
            Text("Name: ${value.habitType}"),
            Text("UUID: ${value.uuid}"),
            Text("Color: ${value.colorType}"),
            Text("DailyGoal: ${value.dailyGoal} ${value.dailyGoalUnit}"),
            Text("Frequency: ${value.frequency}"),
            Text("StartDate: ${value.startDate}"),
            Text("TargetDays: ${value.targetDays}"),
            Text("Desc: ${value.desc}"),
            Text("Mode: ${value.editMode}"),
            Text("CreateT: ${value.createT}"),
            Text("ModifyT: ${value.modifyT}"),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollablePlaceHolder(BuildContext context) {
    return SliverList(
        delegate:
            DebugBuilderMethods.debugBuildSliverScrollDelegate(childCount: 0));
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context, ex: [widget.initForm]);

    //#region private builders
    Widget buildAppbar(BuildContext context) {
      return Selector<HabitFormViewModel,
          Tuple4<String, HabitColorType, bool, bool>>(
        selector: (context, viewmodel) => Tuple4(
            viewmodel.name,
            viewmodel.colorType,
            viewmodel.isAppbarPinned,
            viewmodel.canSaveHabit()),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, data, child) {
          appLog.build
              .debug(context, ex: [data], name: "$widget.Appbar.HabitEdit");
          final name = data.item1;
          final colorType = data.item2;
          final isAppbarPinned = data.item3;
          final canSaveHabit = data.item4;
          return HabitEditAppBar(
            name: name,
            colorType: colorType,
            controller:
                context.read<HabitFormViewModel>().nameFieldInputController,
            scrolledUnderElevation: _kCommonEvalation,
            autofocus: name.isNotEmpty ? false : true,
            isAppbarPinned: isAppbarPinned,
            showSaveButton: canSaveHabit,
            showInFullscreenDialog: widget.showInFullscreenDialog,
            onNameChanged: (value) =>
                context.read<HabitFormViewModel>().name = value,
            onSaveButtonPressed: _onSaveButtonPressed,
          );
        },
      );
    }

    Widget buildColorField(BuildContext context) {
      return Selector<HabitFormViewModel, HabitColorType>(
        selector: (context, formViewModel) => formViewModel.colorType,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, colorType, child) {
          appLog.build
              .debug(context, ex: [colorType], name: "$widget.ColorField");
          return HabitEditColorTile(
            colorType: colorType,
            onPressed: _openColorPickerDialog,
          );
        },
      );
    }

    Widget buildHabitTypeField(BuildContext context) {
      return Selector<HabitFormViewModel, HabitType>(
        selector: (context, formViewModel) => formViewModel.habitType,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, habitType, child) {
          appLog.build
              .debug(context, ex: [habitType], name: "$widget.HabitTypeField");
          return HabitEditHabitTypeTile(
            habitType: habitType,
            onPressed: _openHabitTypePickerDialog,
          );
        },
      );
    }

    Widget buildDailyGoalField(BuildContext context) {
      return Selector<HabitFormViewModel, Tuple2<HabitType, HabitDailyGoal>>(
        selector: (context, vm) => Tuple2(vm.habitType, vm.dailyGoal),
        builder: (context, _, child) {
          final l10n = L10n.of(context);
          final formvm = context.read<HabitFormViewModel>();
          appLog.build.debug(context,
              ex: [formvm.dailyGoal], name: "$widget.DailyGoalField");
          return HabitEditDailyGoalTile(
            errorHint: formvm.isDailyGoalValueValid
                ? null
                : HabitDailyGoalHelper(
                    habitType: formvm.habitType,
                    dailyGoal: formvm.dailyGoal,
                  ).getTileErrorHint(l10n),
            habitType: formvm.habitType,
            defualtHabitDailyGoal:
                HabitDailyGoalHelper.getDefaultDailyGoal(formvm.habitType),
            controller: formvm.dailyGoalFieldInputController,
            onChanged: (value) {
              if (!mounted) return;
              final formvm = context.read<HabitFormViewModel>();
              final newDailyGoal = num.tryParse(value) ??
                  HabitDailyGoalHelper.getDefaultDailyGoal(formvm.habitType);
              formvm.dailyGoal = onDailyGoalTextInputChanged(
                HabitDailyGoalHelper(
                  habitType: formvm.habitType,
                  dailyGoal: newDailyGoal,
                ).validitedGoal,
                controller: formvm.dailyGoalFieldInputController,
                allowInputZero: formvm.allowZeroDailyGoal(),
              );
            },
            onSubmitted: (value) {
              if (!mounted) return;
              final formvm = context.read<HabitFormViewModel>();
              final dailyGoal = HabitDailyGoalHelper(
                habitType: formvm.habitType,
                dailyGoal: formvm.dailyGoal,
              ).validitedGoal;
              if (dailyGoal != formvm.dailyGoal) formvm.dailyGoal = dailyGoal;
              formvm.dailyGoalFieldInputController.text = dailyGoal.toString();
            },
          );
        },
      );
    }

    Widget buildDailyGoalUnitField(BuildContext context) {
      return HabitEditDailyGoalUnitTile(
        controller: context
            .read<HabitFormViewModel>()
            .dailyGoalUnitFieldInputController,
        onChanged: (value) {
          if (!mounted) return;
          final formvm = context.read<HabitFormViewModel>();
          var newValue = value;
          if (value.length <= minHabitDailyGoalUnitLength) {
            formvm.dailyGoalUnitFieldInputController.text = '';
            newValue = defaultHabitDailyGoalUnit;
          } else if (value.length > maxHabitDailyGoalUnitLength) {
            newValue = value.substring(0, maxHabitDailyGoalUnitLength);
          }
          formvm.dailyGoalUnit = newValue;
        },
      );
    }

    Widget buildDailyGoalExtraField(BuildContext context) {
      return Selector<HabitFormViewModel,
          Tuple3<HabitType, HabitDailyGoal?, HabitDailyGoal>>(
        selector: (context, vm) =>
            Tuple3(vm.habitType, vm.dailyGoalExtra, vm.dailyGoal),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, _, child) {
          final formvm = context.read<HabitFormViewModel>();
          return HabitEditDailyGoalExtraTile(
            isValid: formvm.isDailyGoalExtraValueValid,
            habitType: formvm.habitType,
            dailyGoal: formvm.dailyGoal,
            controller: formvm.dailyGoalExtraFieldInpuController,
            onChanged: (value) {
              if (!mounted) return;
              final formvm = context.read<HabitFormViewModel>();
              final newDailyGoalExtra = num.tryParse(value);
              formvm.dailyGoalExtra = newDailyGoalExtra != null
                  ? onDailyGoalTextInputChanged(
                      newDailyGoalExtra,
                      controller: formvm.dailyGoalExtraFieldInpuController,
                      maxValue: maxHabitdailyGoalExtra,
                      allowInputZero: true,
                    )
                  : newDailyGoalExtra;
            },
            onSubmitted: (value) {
              if (!mounted) return;
              final formvm = context.read<HabitFormViewModel>();
              formvm.dailyGoalExtraFieldInpuController.text =
                  formvm.dailyGoalExtra != null
                      ? formvm.dailyGoalExtra.toString()
                      : '';
            },
          );
        },
      );
    }

    Widget buildFrequencyField(BuildContext context) {
      return Selector<HabitFormViewModel, HabitFrequency>(
        selector: (context, formViewModel) => formViewModel.frequency,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, frequency, child) {
          appLog.build
              .debug(context, ex: [frequency], name: "$widget.FrequencyField");
          return HabitEditFrequencyTile(
            frequency: frequency,
            onPressed: _openFrequencyPickerDialog,
          );
        },
      );
    }

    Widget buildStartDateField(BuildContext context) {
      return Selector<HabitFormViewModel,
          Tuple2<HabitStartDate, HabitColorType>>(
        selector: (context, formViewModel) =>
            Tuple2(formViewModel.startDate, formViewModel.colorType),
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, data, child) {
          appLog.build
              .debug(context, ex: [data], name: "$widget.StartDateField");
          final startDate = data.item1;
          final colorType = data.item2;
          return HabitEditStartDateTile(
            startDate: startDate,
            onPressed: (context, date) =>
                _openDatePickerDialog(context, date, colorType),
          );
        },
      );
    }

    Widget buildTargetDaysField(BuildContext context) {
      return Selector<HabitFormViewModel, int>(
        selector: (context, formViewModel) => formViewModel.targetDays,
        builder: (context, targetDays, child) {
          appLog.build.debug(context,
              ex: [targetDays], name: "$widget.TargetDaysField");
          return HabitEditTargetDaysTile(
            targetDays: targetDays,
            onPressed: _openTargetDaysPickerDialog,
          );
        },
      );
    }

    Widget buildRemindarField(BuildContext context) {
      return Selector<HabitFormViewModel, HabitReminder?>(
        selector: (context, vm) => vm.reminder,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, reminder, child) => HabitReminderTiles(
          reminder: reminder,
          reminderQuest: context.read<HabitFormViewModel>().reminderQuest,
          onReminderTimeTilePressed: () =>
              _openTimerPickerDialog(context, reminder),
          onReminderTimeTileCancelButtonPressed:
              _onReminderTimeTileCancelButtonPressed,
          onReminderTypeTilePressed: () =>
              _openReminderTypePickerDialog(context, reminder),
          onReminderQuestTextChange: (value) {
            context.read<HabitFormViewModel>().reminderQuest = value;
          },
        ),
      );
    }

    Widget buildDescField(BuildContext context) {
      return HabitEditDescTile(
        controller: context.read<HabitFormViewModel>().descFieldInputController,
        onDescChanged: (value) =>
            context.read<HabitFormViewModel>().desc = value,
      );
    }

    Widget buildCreateAndModifyTimeField(BuildContext context) {
      return HabitEditCreateAndModifyTile(
        createT: context.read<HabitFormViewModel>().createT!,
        modifyT: context.read<HabitFormViewModel>().modifyT!,
      );
    }
    //#endregion

    //#engion build main
    var formvm = context.read<HabitFormViewModel>();
    return ColorfulNavibar(
      child: Scaffold(
        body: CustomScrollView(
          controller: formvm.verticalScrollController,
          slivers: [
            buildAppbar(context),
            _HabitEditSliverList(
              children: [
                buildColorField(context),
                habitEditDiv,
                buildHabitTypeField(context),
                habitEditDiv,
                buildDailyGoalField(context),
                habitEditDiv,
                buildDailyGoalUnitField(context),
                habitEditDiv,
                buildDailyGoalExtraField(context),
                habitEditDiv,
                buildFrequencyField(context),
                habitEditDiv,
                buildStartDateField(context),
                habitEditDiv,
                buildTargetDaysField(context),
                habitEditDiv,
                buildRemindarField(context),
                habitEditDiv,
                buildDescField(context),
                if (formvm.editMode == HabitDisplayEditMode.edit) ...[
                  habitEditDiv,
                  buildCreateAndModifyTimeField(context),
                ],
                if (context.read<AppDeveloperViewModel>().isInDevelopMode) ...[
                  habitEditDiv,
                  _buildDebugInfo(context),
                ],
                const FixedPagePlaceHolder(),
              ],
            ),
            if (kDebugMode) _buildScrollablePlaceHolder(context),
          ],
        ),
      ),
    );
  }
}

class _HabitEditSliverList extends StatelessWidget {
  final List<Widget> children;

  const _HabitEditSliverList({required this.children});

  @override
  Widget build(BuildContext context) {
    return EnhancedSafeArea.edgeToEdgeSafe(
      withSliver: true,
      child: SliverList(
        delegate: SliverChildListDelegate(children),
      ),
    );
  }
}
