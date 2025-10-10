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

import '../../common/consts.dart';
import '../../common/rules.dart';
import '../../common/types.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/num_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../models/habit_daily_goal.dart';
import '../../models/habit_display.dart';
import '../../models/habit_form.dart';
import '../../models/habit_freq.dart';
import '../../models/habit_reminder.dart';
import '../../providers/app_caches.dart';
import '../../providers/app_developer.dart';
import '../../providers/app_first_day.dart';
import '../../providers/app_sync.dart';
import '../../providers/habit_form.dart';
import '../../reminders/notification_channel.dart';
import '../../reminders/notification_id_range.dart' as notifyid;
import '../../reminders/notification_service.dart';
import '../../storage/db/handlers/habit.dart';
import '../../widgets/widgets.dart';
import '../common/debug.dart';
import 'widgets.dart';

Future<HabitDBCell?> naviToHabitEidtPage({
  required BuildContext context,
  required HabitForm initForm,
  bool? naviWithFullscreenDialog,
}) async {
  return Navigator.of(context).push<HabitDBCell>(
    MaterialPageRoute(
      fullscreenDialog: naviWithFullscreenDialog ?? true,
      builder: (context) => HabitEditPage(
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
class HabitEditPage extends StatelessWidget {
  final HabitForm? initForm;
  final bool showInFullscreenDialog;

  const HabitEditPage({
    super.key,
    this.initForm,
    this.showInFullscreenDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return PageProviders(
        initForm: initForm,
        child: _Page(
            initForm: initForm,
            showInFullscreenDialog: showInFullscreenDialog));
  }
}

class _Page extends StatefulWidget {
  final HabitForm? initForm;
  final bool showInFullscreenDialog;

  const _Page({
    this.initForm,
    this.showInFullscreenDialog = false,
  });

  @override
  State<StatefulWidget> createState() => _PageState();
}

class _PageState extends State<_Page> {
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
    if (result == null || !context.mounted) return;
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
    if (result == null || !context.mounted) return;
    context.read<HabitFormViewModel>().frequency = result;
  }

  void _openDatePickerDialog(BuildContext context, DateTime startDate,
      HabitColorType colorType) async {
    final result = await showHabitDatePickerDialog(
        context: context, date: startDate, colorType: colorType);
    appLog.navi.info("$runtimeType._openDatePickerDialog", ex: [result]);
    if (result == null || !context.mounted) return;
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
    if (result == null || !context.mounted) return;
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
    if (!context.mounted || result == null) return;
    context.read<HabitFormViewModel>().reminder = context
        .read<HabitFormViewModel>()
        .reminder
        ?.copyWith(type: result.type, extra: result.extra);
  }

  void _openTimerPickerDialog(
      BuildContext context, HabitReminder? reminder) async {
    await NotificationService().requestPermissions();
    if (!context.mounted) return;
    final result =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (!context.mounted || result == null) return;
    final newReminder = (context.read<HabitFormViewModel>().reminder ??
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
    // add or remove reminder
    final uuid = result?.uuid;
    final dbid = result?.id;
    if (uuid != null) {
      final details = context.read<NotificationChannelData>().habitReminder;
      formvm
          .loadSingleHabitSummaryFromDB(uuid,
              firstDay: context.read<AppFirstDayViewModel>().firstDay)
          .then((habit) {
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
        } else if (dbid != null) {
          NotificationService().cancelHabitReminder(
            id: notifyid.getHabitReminderId(dbid),
          );
        }
      });
    }
    // pop result
    Navigator.of(context).pop(result);
    // try sync once
    if (mounted && result != null) {
      final appSync = context.maybeRead<AppSyncViewModel>();
      if (appSync != null && appSync.mounted) appSync.delayedStartTaskOnce();
    }
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
            Text("DailyGoal: ${value.dailyGoalValue} ${value.dailyGoalUnit}"),
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
    return SliverList(delegate: debugBuildSliverScrollDelegate(childCount: 0));
  }

  @override
  Widget build(BuildContext context) {
    appLog.build.debug(context, ex: [widget.initForm]);

    //#region private builders
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

    Widget buildCreateAndModifyTimeField(BuildContext context) {
      return HabitEditCreateAndModifyTile(
        createT: context.read<HabitFormViewModel>().createT!,
        modifyT: context.read<HabitFormViewModel>().modifyT!,
      );
    }
    //#endregion

    //#engion build main
    final formvm = context.read<HabitFormViewModel>();
    return ColorfulNavibar(
      child: Scaffold(
        body: CustomScrollView(
          controller: formvm.verticalScrollController,
          slivers: [
            _Appbar(
                showInFullscreenDialog: widget.showInFullscreenDialog,
                onSaveButtonPressed: _onSaveButtonPressed),
            _HabitEditSliverList(
              children: [
                buildColorField(context),
                kHabitDivider,
                buildHabitTypeField(context),
                kHabitDivider,
                const _DailyGoalField(),
                kHabitDivider,
                const _DailyGoalUnitField(),
                kHabitDivider,
                const _DailyGoalExtraField(),
                kHabitDivider,
                buildFrequencyField(context),
                kHabitDivider,
                buildStartDateField(context),
                kHabitDivider,
                buildTargetDaysField(context),
                kHabitDivider,
                buildRemindarField(context),
                kHabitDivider,
                const _DescField(),
                if (formvm.editMode == HabitDisplayEditMode.edit) ...[
                  kHabitDivider,
                  buildCreateAndModifyTimeField(context),
                ],
                if (context.read<AppDeveloperViewModel>().isInDevelopMode) ...[
                  kHabitDivider,
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

final class _Appbar extends StatelessWidget {
  final bool showInFullscreenDialog;
  final VoidCallback? onSaveButtonPressed;

  const _Appbar(
      {required this.showInFullscreenDialog, this.onSaveButtonPressed});

  @override
  Widget build(BuildContext context) {
    return HabitEditFormInputField(
      valueBuilder: (vm) => vm.name,
      builder: (context, controller, child) {
        final (name, colorType, pinned, canSave) = context
            .select<HabitFormViewModel, (String, HabitColorType, bool, bool)>(
                (vm) => (
                      vm.name,
                      vm.colorType,
                      vm.isAppbarPinned,
                      vm.canSaveHabit()
                    ));
        appLog.build.debug(context,
            ex: [name, colorType, pinned, canSave],
            name: "HabitEditPage.Appbar");
        return HabitEditAppBar(
          name: name,
          colorType: colorType,
          controller: controller,
          scrolledUnderElevation: kHabitEditCommonEvalation,
          autofocus: name.isNotEmpty ? false : true,
          isAppbarPinned: pinned,
          showSaveButton: canSave,
          showInFullscreenDialog: showInFullscreenDialog,
          onNameChanged: (value) {
            final vm = context.read<HabitFormViewModel>();
            if (vm.mounted) vm.name = value;
          },
          onSaveButtonPressed: onSaveButtonPressed,
        );
      },
    );
  }
}

final class _DailyGoalField extends StatelessWidget {
  const _DailyGoalField();

  String? getTileErrorHint(HabitType type, HabitDailyGoal dailyGoal,
      [L10n? l10n]) {
    switch (type) {
      case HabitType.unknown:
      case HabitType.normal:
        if (dailyGoal <= minHabitDailyGoal) {
          return l10n?.habitEdit_habitDailyGoal_errorText01(minHabitDailyGoal);
        } else if (dailyGoal > maxHabitdailyGoal) {
          return l10n?.habitEdit_habitDailyGoal_errorText02(maxHabitdailyGoal);
        } else {
          return null;
        }
      case HabitType.negative:
        if (dailyGoal < minHabitDailyGoal) {
          return l10n
              ?.habitEdit_habitDailyGoal_negativeErrorText01(minHabitDailyGoal);
        } else if (dailyGoal > maxHabitdailyGoal) {
          return l10n
              ?.habitEdit_habitDailyGoal_negativeErrorText02(minHabitDailyGoal);
        } else {
          return null;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final habitType =
        context.select<HabitFormViewModel, HabitType>((vm) => vm.habitType);
    return HabitEditFormInputField(
      valueBuilder: (vm) => vm.dailyGoal.normalizedGoal.toSimpleString(),
      builder: (context, controller, child) {
        final (dailyGoal, defaultDailyGoal, isDailyGoalValid) = context
            .select<HabitFormViewModel, (HabitDailyGoal, HabitDailyGoal, bool)>(
                (vm) => (
                      vm.dailyGoalValue,
                      vm.dailyGoal.defaultDailyGoal,
                      vm.isDailyGoalValueValid
                    ));
        appLog.build.debug(context,
            ex: [habitType, dailyGoal], name: "HabitEditPage.DailyGoalField");
        return HabitEditDailyGoalTile(
          errorHint: isDailyGoalValid
              ? null
              : getTileErrorHint(habitType, dailyGoal, l10n),
          habitType: habitType,
          defualtHabitDailyGoal: defaultDailyGoal,
          controller: controller,
          onChanged: (value) {
            final vm = context.read<HabitFormViewModel>();
            if (!vm.mounted) return;
            final newDailyGoal =
                HabitDailyGoal.tryParse(value) ?? vm.dailyGoal.defaultDailyGoal;
            vm.dailyGoalValue = onDailyGoalTextInputChanged(
              HabitDailyGoalContainer(
                      type: vm.habitType, dailyGoal: newDailyGoal)
                  .normalizedGoal,
              controller: controller,
              allowInputZero: vm.allowZeroDailyGoal(),
            );
          },
          onSubmitted: (value) {
            final vm = context.read<HabitFormViewModel>();
            if (!vm.mounted) return;
            final dailyGoal = vm.dailyGoal.normalizedGoal;
            if (dailyGoal != vm.dailyGoalValue) vm.dailyGoalValue = dailyGoal;
            controller.text = dailyGoal.toSimpleString();
          },
        );
      },
    );
  }
}

final class _DailyGoalExtraField extends StatelessWidget {
  const _DailyGoalExtraField();

  @override
  Widget build(BuildContext context) {
    final habitType =
        context.select<HabitFormViewModel, HabitType>((vm) => vm.habitType);
    return HabitEditFormInputField(
      valueBuilder: (vm) => vm.dailyGoalExtra?.toSimpleString() ?? '',
      builder: (context, controller, child) {
        final (dailyGoalExtra, dailyGoal, isDailyGoalExtraValid) =
            context.select<HabitFormViewModel,
                    (HabitDailyGoal?, HabitDailyGoal, bool)>(
                (vm) => (
                      vm.dailyGoalExtra,
                      vm.dailyGoalValue,
                      vm.isDailyGoalExtraValueValid
                    ));
        return HabitEditDailyGoalExtraTile(
          isValid: isDailyGoalExtraValid,
          habitType: habitType,
          dailyGoal: dailyGoal,
          controller: controller,
          onChanged: (value) {
            final vm = context.read<HabitFormViewModel>();
            if (!vm.mounted) return;
            final newDailyGoalExtra = num.tryParse(value);
            vm.dailyGoalExtra = newDailyGoalExtra != null
                ? onDailyGoalTextInputChanged(
                    newDailyGoalExtra,
                    controller: controller,
                    maxValue: maxHabitdailyGoalExtra,
                    allowInputZero: true,
                  )
                : newDailyGoalExtra;
          },
          onSubmitted: (value) {
            final vm = context.read<HabitFormViewModel>();
            if (!vm.mounted) return;
            controller.text =
                vm.dailyGoalExtra != null ? vm.dailyGoalExtra.toString() : '';
          },
        );
      },
    );
  }
}

final class _DailyGoalUnitField extends StatelessWidget {
  const _DailyGoalUnitField();

  @override
  Widget build(BuildContext context) {
    return HabitEditFormInputField(
      valueBuilder: (vm) => vm.dailyGoalUnit,
      builder: (context, controller, child) => HabitEditDailyGoalUnitTile(
        controller: controller,
        onChanged: (value) {
          final vm = context.read<HabitFormViewModel>();
          if (!vm.mounted) return;
          final String newValue;
          if (value.length <= minHabitDailyGoalUnitLength) {
            controller.text = '';
            newValue = defaultHabitDailyGoalUnit;
          } else if (value.length > maxHabitDailyGoalUnitLength) {
            newValue = value.substring(0, maxHabitDailyGoalUnitLength);
          } else {
            newValue = value;
          }
          vm.dailyGoalUnit = newValue;
        },
      ),
    );
  }
}

final class _DescField extends StatelessWidget {
  const _DescField();

  @override
  Widget build(BuildContext context) {
    return HabitEditFormInputField(
      valueBuilder: (vm) => vm.desc,
      builder: (context, controller, child) => HabitEditDescTile(
        controller: controller,
        onDescChanged: (value) {
          final vm = context.read<HabitFormViewModel>();
          if (vm.mounted) vm.desc = value;
        },
      ),
    );
  }
}
