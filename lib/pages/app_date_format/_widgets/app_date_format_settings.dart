// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/custom_date_format.dart';
import '../../../providers/app_ui/app_custom_date_format.dart';

class AppDateFormatSettings extends StatelessWidget {
  const AppDateFormatSettings({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      AdaptiveListSection(children: [_UseSystemFormatTile()]),
      _CustomDateFormatSections(),
    ],
  );
}

class _CustomDateFormatSections extends StatelessWidget {
  const _CustomDateFormatSections();

  @override
  Widget build(BuildContext context) {
    final useSystemFormat = context
        .select<AppCustomDateYmdHmsConfigViewModel, bool>(
          (vm) => vm.config.useSystemFormat,
        );
    if (useSystemFormat) return const SizedBox.shrink();

    return const Column(
      children: [
        AdaptiveListSection(children: [_DateOrderTile(), _DateSeparatorTile()]),
        AdaptiveListSection(
          children: [_TwelveHourTile(), _MonthNameTile(), _LeadingZeroTile()],
        ),
        AdaptiveListSection(
          children: [_ApplyFrequencyChartTile(), _ApplyCalendarTile()],
        ),
      ],
    );
  }
}

class _UseSystemFormatTile extends StatelessWidget {
  const _UseSystemFormatTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select<AppCustomDateYmdHmsConfigViewModel, bool>(
      (vm) => vm.config.useSystemFormat,
    );
    final l10n = L10n.of(context);
    return AdaptiveSwitchListTile(
      key: const ValueKey('date-format-use-system'),
      title: Text(
        l10n?.common_customDateTimeFormatPicker_useSystemFormat_text ??
            'Use system format',
      ),
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(useSystemFormat: value));
      },
    );
  }
}

class _DateOrderTile extends StatelessWidget {
  const _DateOrderTile();

  @override
  Widget build(BuildContext context) {
    final value = context
        .select<AppCustomDateYmdHmsConfigViewModel, YearMonthDayFormtEnum>(
          (vm) => vm.config.ymdFormat,
        );
    final l10n = L10n.of(context);
    final labels = {
      for (final option in YearMonthDayFormtEnum.values)
        option: const CustomDateYmdHmsConfig.withDefault()
            .copyWith(ymdFormat: option)
            .getYearMonthDayDisplayText(l10n),
    };
    return AdaptiveChoiceListTile<YearMonthDayFormtEnum>(
      title: Text(
        l10n?.common_customDateTimeFormatPicker_fmtTileText ?? 'Date format',
      ),
      labels: labels,
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(ymdFormat: value));
      },
      config: switch (AdaptiveStyle.of(context)) {
        AdaptiveStyle.material => const AdaptiveChoiceListTileConfig.choice(),
        AdaptiveStyle.apple => const AdaptiveChoiceListTileConfig(
          segmented: AdaptiveChoiceLayout.stacked,
        ),
      },
      controlKey: const ValueKey('date-format-order'),
    );
  }
}

class _DateSeparatorTile extends StatelessWidget {
  const _DateSeparatorTile();

  @override
  Widget build(BuildContext context) {
    final value = context
        .select<AppCustomDateYmdHmsConfigViewModel, DateSplitCharEnum>(
          (vm) => vm.config.splitChar,
        );
    final l10n = L10n.of(context);
    final labels = {
      for (final option in DateSplitCharEnum.values)
        option: const CustomDateYmdHmsConfig.withDefault()
            .copyWith(splitChar: option)
            .getSplitCharDisplayText(l10n),
    };
    return AdaptiveChoiceListTile<DateSplitCharEnum>(
      title: Text(
        l10n?.common_customDateTimeFormatPicker_SepTileText ?? 'Separator',
      ),
      labels: labels,
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(splitChar: value));
      },
      controlKey: const ValueKey('date-format-separator'),
    );
  }
}

class _TwelveHourTile extends StatelessWidget {
  const _TwelveHourTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select<AppCustomDateYmdHmsConfigViewModel, bool>(
      (vm) => vm.config.twelveHoursOn,
    );
    final l10n = L10n.of(context);
    return AdaptiveSwitchListTile(
      title: Text(
        l10n?.common_customDateTimeFormatPicker_12Hour_text ??
            'Use 12-hour format',
      ),
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(twelveHoursOn: value));
      },
    );
  }
}

class _MonthNameTile extends StatelessWidget {
  const _MonthNameTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select<AppCustomDateYmdHmsConfigViewModel, bool>(
      (vm) => vm.config.useMonthWithName,
    );
    final l10n = L10n.of(context);
    return AdaptiveSwitchListTile(
      title: Text(
        l10n?.common_customDateTimeFormatPicker_monthName_text ??
            'Use full name',
      ),
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(useMonthWithName: value));
      },
    );
  }
}

class _LeadingZeroTile extends StatelessWidget {
  const _LeadingZeroTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select<AppCustomDateYmdHmsConfigViewModel, bool>(
      (vm) => vm.config.useLeadingZero,
    );
    final l10n = L10n.of(context);
    return AdaptiveSwitchListTile(
      title: Text(l10n?.appDateFormat_leadingZero_text ?? 'Use leading zeros'),
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(useLeadingZero: value));
      },
    );
  }
}

class _ApplyFrequencyChartTile extends StatelessWidget {
  const _ApplyFrequencyChartTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select<AppCustomDateYmdHmsConfigViewModel, bool>(
      (vm) => vm.config.isApplyFreqChart,
    );
    final l10n = L10n.of(context);
    return AdaptiveSwitchListTile(
      title: Text(
        l10n?.common_customDateTimeFormatPicker_applyFreqChart_text ??
            'Apply to frequency chart',
      ),
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(applyFreqChart: value));
      },
    );
  }
}

class _ApplyCalendarTile extends StatelessWidget {
  const _ApplyCalendarTile();

  @override
  Widget build(BuildContext context) {
    final value = context.select<AppCustomDateYmdHmsConfigViewModel, bool>(
      (vm) => vm.config.isApplyHeatmapCal,
    );
    final l10n = L10n.of(context);
    return AdaptiveSwitchListTile(
      title: Text(
        l10n?.common_customDateTimeFormatPicker_applyHeapmap_text ??
            'Apply to calendar',
      ),
      value: value,
      onChanged: (value) {
        final vm = context.read<AppCustomDateYmdHmsConfigViewModel>();
        vm.setNewConfig(vm.config.copyWith(applyHeatmapCal: value));
      },
    );
  }
}
