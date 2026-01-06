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
import 'package:intl/intl.dart';

import '../../../common/consts.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';

Future<int?> showAppSettingFirstDaySelectDialog({
  required BuildContext context,
  int? firstDay,
}) async {
  return showDialog<int>(
    context: context,
    builder: (context) =>
        AppSettingFirstDaySelectDialog(initFirstday: firstDay),
  );
}

class AppSettingFirstDayTile extends StatelessWidget {
  final int firstDay;
  final VoidCallback? onPressed;

  const AppSettingFirstDayTile({
    super.key,
    required this.firstDay,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      title: l10n != null
          ? Text(l10n.appSetting_firstDayOfWeek_titleText)
          : const Text("First day of week"),
      subtitle: Text(
        DateFormat.EEEE(
          l10n?.localeName,
        ).format(getProtoDateWithFirstDay(firstDay)),
      ),
      onTap: onPressed,
    );
  }
}

class AppSettingFirstDaySelectDialog extends StatelessWidget {
  final int? initFirstday;

  const AppSettingFirstDaySelectDialog({super.key, this.initFirstday});

  Widget _buildSimpleDialogOption(
    BuildContext context,
    int firstday, {
    L10n? l10n,
  }) {
    var text = DateFormat.EEEE(
      l10n?.localeName,
    ).format(getProtoDateWithFirstDay(firstday));
    if (firstday == defaultFirstDay) {
      text +=
          (l10n?.appSetting_firstDayOfWeekDialog_defaultText ?? " (Default)");
    }
    return SimpleDialogOption(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          if (initFirstday == firstday) const Icon(Icons.check),
        ],
      ),
      onPressed: () => Navigator.of(context).pop(firstday),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return SimpleDialog(
      title: l10n != null
          ? Text(l10n.appSetting_firstDayOfWeekDialog_titleText)
          : const Text("Show first day of week"),
      children: List<Widget>.generate(
        DateTime.daysPerWeek,
        (index) => _buildSimpleDialogOption(context, index + 1, l10n: l10n),
      ),
    );
  }
}
