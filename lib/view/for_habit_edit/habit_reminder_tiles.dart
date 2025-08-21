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
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../component/widget.dart';
import '../../extension/colorscheme_extensions.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_reminder.dart';

class HabitReminderTiles extends StatefulWidget {
  final HabitReminder? reminder;
  final String? reminderQuest;
  final VoidCallback? onReminderTimeTilePressed;
  final VoidCallback? onReminderTimeTileCancelButtonPressed;
  final VoidCallback? onReminderTypeTilePressed;
  final ValueChanged<String>? onReminderQuestTextChange;

  const HabitReminderTiles({
    super.key,
    this.reminder,
    this.reminderQuest,
    this.onReminderTimeTilePressed,
    this.onReminderTimeTileCancelButtonPressed,
    this.onReminderTypeTilePressed,
    this.onReminderQuestTextChange,
  });

  @override
  State<StatefulWidget> createState() => _HabitReminderTiles();
}

class _HabitReminderTiles extends State<HabitReminderTiles> {
  late final TextEditingController _questTextController;

  @override
  void initState() {
    _questTextController = TextEditingController()
      ..text = widget.reminderQuest ?? '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _questTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    Widget buildReminderTimeTile(BuildContext context) {
      return ListTile(
        leading: Icon(
          Icons.notifications_outlined,
          color: Theme.of(context).colorScheme.outline,
        ),
        trailing: widget.reminder != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () =>
                    widget.onReminderTimeTileCancelButtonPressed?.call(),
              )
            : null,
        title: widget.reminder != null
            ? Text(widget.reminder!.time.format(context))
            : l10n != null
                ? Text(l10n.habitEdit_reminder_hintText)
                : const Text('Reminder'),
        textColor: widget.reminder != null
            ? null
            : Theme.of(context).colorScheme.outlineOpacity64,
        onTap: widget.onReminderTimeTilePressed,
      );
    }

    Widget buildReminderTypeTile(BuildContext context) {
      final text = widget.reminder?.getReminderTypeHelperText(l10n);
      return ListTile(
        leading: const Icon(MdiIcons.arrowRightBottom),
        title: text != null ? Text(text) : const Text(''),
        onTap: widget.onReminderTypeTilePressed,
      );
    }

    Widget buildReminderQuestTile(BuildContext context) {
      final ThemeData themeData = Theme.of(context);
      final ColorScheme colorScheme = themeData.colorScheme;
      final TextTheme textTheme = themeData.textTheme;
      return ListTile(
        leading: const SizedBox(),
        title: TextField(
          controller: _questTextController,
          decoration: InputDecoration(
              hintText: l10n?.habitEdit_reminderQuest_hintText,
              hintStyle: TextStyle(color: colorScheme.outlineOpacity64),
              border: InputBorder.none),
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
            LengthLimitingTextInputFormatter(200),
          ],
          style: textTheme.bodyLarge,
          maxLines: null,
          onChanged: widget.onReminderQuestTextChange,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(builder: buildReminderTimeTile),
        ExpandedSection(
          expand: widget.reminder != null,
          child: Column(
            children: [
              Builder(builder: buildReminderTypeTile),
              Builder(builder: buildReminderQuestTile),
            ],
          ),
        ),
      ],
    );
  }
}
