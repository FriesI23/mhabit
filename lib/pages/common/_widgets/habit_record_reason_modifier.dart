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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/consts.dart';
import '../../../extensions/colorscheme_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../models/habit_date.dart';
import '../../../models/habit_form.dart';
import '../../../widgets/widgets.dart';

Future<String?> showHabitRecordReasonModifierDialog({
  required BuildContext context,
  String initReason = '',
  HabitDate? recordDate,
  List<String> chipTextList = const [],
  HabitColorType? colorType,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => ThemeWithCustomColors(
      colorType: colorType,
      child: HabitRecordReasonModifierDialog(
        initReson: initReason,
        recordDate: recordDate,
        chipTextList: chipTextList,
      ),
    ),
  );
}

class HabitRecordReasonModifierDialog extends StatefulWidget {
  final String initReson;
  final HabitDate? recordDate;
  final List<String> chipTextList;

  const HabitRecordReasonModifierDialog({
    super.key,
    this.initReson = '',
    this.recordDate,
    this.chipTextList = const [],
  });

  @override
  State<StatefulWidget> createState() => _HabitRecordReasonModifierDialog();
}

class _HabitRecordReasonModifierDialog
    extends State<HabitRecordReasonModifierDialog> {
  static const double dialogMaxWidth = 400.0;

  late final TextEditingController _inputController;

  @override
  void initState() {
    _inputController = TextEditingController(text: widget.initReson);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return AlertDialog(
          scrollable: true,
          title: l10n != null
              ? Text(l10n.habitDetail_skipReason_title)
              : const Text("Skip reason"),
          insetPadding: kExpanedDailogInsetPadding,
          contentPadding: const EdgeInsets.only(left: 24.0, right: 24.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HabitRecordReasonField(
                chipHeight: 56,
                chipWidth: math.min(constraints.maxWidth, dialogMaxWidth),
                recordDate: widget.recordDate,
                chipTextList: widget.chipTextList,
                inputController: _inputController,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: OverflowBar(
                  spacing: 8.0,
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: l10n != null
                          ? Text(l10n.habitDetail_skipReason_cancelText)
                          : const Text('cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, _inputController.text);
                      },
                      child: l10n != null
                          ? Text(l10n.habitDetail_skipReason_saveText)
                          : const Text('save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HabitRecordReasonField extends StatelessWidget {
  final double? chipHeight;
  final double? chipWidth;
  final HabitDate? recordDate;
  final List<String> chipTextList;
  final TextEditingController inputController;
  final ValueChanged<String>? onChanged;

  const HabitRecordReasonField({
    super.key,
    this.chipHeight,
    this.chipWidth,
    this.recordDate,
    this.chipTextList = const [],
    required this.inputController,
    this.onChanged,
  });

  Widget _buildEmojiChip(BuildContext context, String emoji) {
    final themeData = Theme.of(context);
    return ActionChip(
      iconTheme: IconThemeData(color: themeData.colorScheme.primary),
      label: Text(emoji),
      onPressed: () {
        var cursorPosition = inputController.selection.baseOffset;
        if (cursorPosition < 0) {
          cursorPosition = inputController.text.length;
        }
        final oldText = inputController.text;
        final newText = oldText.replaceRange(
          cursorPosition,
          cursorPosition,
          emoji,
        );
        inputController.text = newText;
        inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPosition + emoji.length),
        );
        onChanged?.call(inputController.text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final themeData = Theme.of(context);
    Widget emojiChipBuilder(e) => _buildEmojiChip(context, e);

    return Column(
      children: [
        ChipList(
          height: chipHeight,
          width: chipWidth,
          padding: EdgeInsets.zero,
          children: chipTextList.map(emojiChipBuilder).toList(),
        ),
        TextField(
          controller: inputController,
          maxLength: maxRecordReasonTextLenth,
          decoration: InputDecoration(
            hintText:
                l10n?.habitDetail_skipReason_bodyHelpText ??
                "Write something here...",
            hintStyle: TextStyle(color: themeData.colorScheme.outlineOpacity64),
            helperText: recordDate != null
                ? DateFormat.yMMMd(l10n?.localeName).format(recordDate!)
                : null,
          ),
          keyboardType: TextInputType.text,
          style: themeData.textTheme.bodyLarge,
          minLines: 1,
          maxLines: 4,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
