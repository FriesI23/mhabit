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

import 'package:flutter/material.dart';

import '../../component/widget.dart';
import '../../l10n/localizations.dart';
import '../../model/custom_date_format.dart';

Future<CustomDateYmdHmsConfig?> showCustomDateTimeFormatPickerDialog({
  required BuildContext context,
  CustomDateYmdHmsConfig? config,
}) async {
  return showDialog<CustomDateYmdHmsConfig>(
    context: context,
    builder: (context) => CustomDateTimeFormatPickerDialog(initConfig: config),
  );
}

class CustomDateTimeFormatPickerDialog extends StatefulWidget {
  final CustomDateYmdHmsConfig? initConfig;

  const CustomDateTimeFormatPickerDialog({super.key, this.initConfig});

  @override
  State<StatefulWidget> createState() =>
      _CustomDateTimeFormatPickerDialogState();
}

class _CustomDateTimeFormatPickerDialogState
    extends State<CustomDateTimeFormatPickerDialog> {
  late CustomDateYmdHmsConfig _crtConfig;
  late DateTime _templateDateTime;

  @override
  void initState() {
    if (widget.initConfig == null) {
      _crtConfig = const CustomDateYmdHmsConfig.withDefault();
    } else {
      _crtConfig = widget.initConfig!;
    }
    _templateDateTime = DateTime.now();
    super.initState();
  }

  void _onUseSystemStyleSwitchChanged(bool? value) {
    if (value != null) {
      setState(() {
        _crtConfig = _crtConfig.copyWith(useSystemFormat: value);
      });
    }
  }

  void _onYMDFormatChanged(YearMonthDayFormtEnum? newFormat) {
    setState(() {
      _crtConfig =
          _crtConfig.copyWith(ymdFormat: newFormat ?? _crtConfig.ymdFormat);
    });
  }

  void _onSplitCharChanged(DateSplitCharEnum? newChar) {
    setState(() {
      _crtConfig =
          _crtConfig.copyWith(splitChar: newChar ?? _crtConfig.splitChar);
    });
  }

  void _on12HourSwitchChanged(bool value) {
    setState(() {
      _crtConfig = _crtConfig.copyWith(twelveHoursOn: value);
    });
  }

  void _onUseFullMonthNameChanged(bool value) {
    setState(() {
      _crtConfig = _crtConfig.copyWith(useMonthWithName: value);
    });
  }

  void _onUseLeadingZeroChanged(bool value) {
    setState(() {
      _crtConfig = _crtConfig.copyWith(useLeadingZero: value);
    });
  }

  void _onApplyForFreqChartChanged(bool value) {
    setState(() {
      _crtConfig = _crtConfig.copyWith(applyFreqChart: value);
    });
  }

  void _onApplyForHeatmapCalChanged(bool value) {
    setState(() {
      _crtConfig = _crtConfig.copyWith(applyHeatmapCal: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    const div = Divider();

    Widget buildTitle(BuildContext context, {L10n? l10n}) {
      final formatter = _crtConfig.getFormatter(l10n?.localeName);
      return SizedBox(
        height: MediaQuery.textScalerOf(context)
            .clamp(maxScaleFactor: 1.3)
            .scale(40.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: FittedBox(
            key: ValueKey<String>(formatter.pattern ?? ''),
            fit: BoxFit.fitWidth,
            child: Text(
              formatter.format(_templateDateTime),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    Widget buildYMDFormatSelectListTile(
        BuildContext context, YearMonthDayFormtEnum value,
        {L10n? l10n}) {
      final text = _crtConfig
          .copyWith(ymdFormat: value)
          .getYearMonthDayDisplayText(l10n);
      return RadioListTile<YearMonthDayFormtEnum>(
        title: Text(text),
        contentPadding: EdgeInsets.zero,
        groupValue: _crtConfig.ymdFormat,
        value: value,
        onChanged: _onYMDFormatChanged,
      );
    }

    Widget buildSplitCharSelectListTile(
        BuildContext context, DateSplitCharEnum char,
        {L10n? l10n}) {
      final text =
          _crtConfig.copyWith(splitChar: char).getSplitCharDisplayText(l10n);
      return RadioListTile<DateSplitCharEnum>(
        title: Text(text),
        contentPadding: EdgeInsets.zero,
        groupValue: _crtConfig.splitChar,
        value: char,
        onChanged: _onSplitCharChanged,
      );
    }

    Widget buildUseSystemFormat(BuildContext context, {L10n? l10n}) {
      return CheckboxListTile(
        title: l10n != null
            ? Text(l10n.common_customDateTimeFormatPicker_useSystemFormat_text)
            : const Text("Use system format"),
        contentPadding: EdgeInsets.zero,
        value: _crtConfig.useSystemFormat,
        onChanged: _onUseSystemStyleSwitchChanged,
      );
    }

    Widget buildUse12HoursListTile(BuildContext context, {L10n? l10n}) {
      return SwitchListTile(
        title: l10n != null
            ? Text(l10n.common_customDateTimeFormatPicker_12Hour_text)
            : const Text("Use 12 hours"),
        contentPadding: EdgeInsets.zero,
        value: _crtConfig.twelveHoursOn,
        onChanged: _on12HourSwitchChanged,
      );
    }

    Widget buildUseFullMonthNameListTile(BuildContext context, {L10n? l10n}) {
      return SwitchListTile(
        title: l10n != null
            ? Text(l10n.common_customDateTimeFormatPicker_monthName_text)
            : const Text("Use full month name"),
        contentPadding: EdgeInsets.zero,
        value: _crtConfig.useMonthWithName,
        onChanged: _onUseFullMonthNameChanged,
      );
    }

    Widget buildUseLeadingZeroListTile(BuildContext context, {L10n? l10n}) {
      return SwitchListTile(
        title: const Text("Use Leading Zero"),
        contentPadding: EdgeInsets.zero,
        value: _crtConfig.useLeadingZero,
        onChanged: _onUseLeadingZeroChanged,
      );
    }

    Widget buildApplyFreqChartListTile(BuildContext context, {L10n? l10n}) {
      return SwitchListTile(
        title: l10n != null
            ? Text(l10n.common_customDateTimeFormatPicker_applyFreqChart_text)
            : const Text("Apply for freq chart"),
        contentPadding: EdgeInsets.zero,
        value: _crtConfig.isApplyFreqChart,
        onChanged: _onApplyForFreqChartChanged,
      );
    }

    Widget buildApplHeapmapCalListTile(BuildContext context, {L10n? l10n}) {
      return SwitchListTile(
        title: l10n != null
            ? Text(l10n.common_customDateTimeFormatPicker_applyHeapmap_text)
            : const Text("Apply for heatmap calendar"),
        contentPadding: EdgeInsets.zero,
        value: _crtConfig.isApplyHeatmapCal,
        onChanged: _onApplyForHeatmapCalChanged,
      );
    }

    List<Widget> buildActions(BuildContext context, {L10n? l10n}) {
      return [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: l10n != null
              ? Text(l10n.common_customDateTimeFormatPicker_cancelButton_text)
              : const Text('cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _crtConfig);
          },
          child: l10n != null
              ? Text(l10n.common_customDateTimeFormatPicker_confirmButton_text)
              : const Text('confirm'),
        ),
      ];
    }

    return L10nBuilder(
      builder: (context, l10n) => AlertDialog(
        scrollable: false,
        title: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: double.infinity,
            minWidth: 400,
          ),
          child: Center(
            child: buildTitle(context, l10n: l10n),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              buildUseSystemFormat(context, l10n: l10n),
              ExpandedSection(
                expand: !_crtConfig.useSystemFormat,
                child: Column(
                  children: [
                    // ymd format part
                    if (l10n != null)
                      GroupTitleListTile(
                        title: Text(
                          l10n.common_customDateTimeFormatPicker_fmtTileText,
                        ),
                      ),
                    for (var i in YearMonthDayFormtEnum.values)
                      buildYMDFormatSelectListTile(context, i, l10n: l10n),
                    // split char part
                    if (l10n != null)
                      GroupTitleListTile(
                        title: Text(
                          l10n.common_customDateTimeFormatPicker_SepTileText,
                        ),
                      ),
                    for (var i in DateSplitCharEnum.values)
                      buildSplitCharSelectListTile(context, i, l10n: l10n),
                    div,
                    buildUse12HoursListTile(context, l10n: l10n),
                    buildUseFullMonthNameListTile(context, l10n: l10n),
                    buildUseLeadingZeroListTile(context, l10n: l10n),
                    div,
                    buildApplyFreqChartListTile(context, l10n: l10n),
                    buildApplHeapmapCalListTile(context, l10n: l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: buildActions(context, l10n: l10n),
      ),
    );
  }
}
