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
import '../../extension/custom_color_extensions.dart';
import '../../l10n/localizations.dart';
import '../../model/habit_form.dart';
import '../../theme/color.dart';

class HabitEditAppBar extends StatelessWidget {
  final String name;
  final HabitColorType colorType;
  final TextEditingController? controller;
  final double? scrolledUnderElevation;
  final bool autofocus;
  final bool isAppbarPinned;
  final bool showInFullscreenDialog;
  final bool showSaveButton;
  final ValueChanged<String>? onNameChanged;
  final VoidCallback? onSaveButtonPressed;

  const HabitEditAppBar({
    super.key,
    required this.name,
    required this.colorType,
    this.controller,
    this.scrolledUnderElevation,
    required this.autofocus,
    required this.isAppbarPinned,
    required this.showInFullscreenDialog,
    this.showSaveButton = true,
    this.onNameChanged,
    this.onSaveButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorData = themeData.extension<CustomColors>();
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    Widget buildInputForm(BuildContext context) {
      return TextField(
        maxLines: 1,
        minLines: 1,
        controller: controller,
        autofocus: autofocus,
        enabled: !isAppbarPinned,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          hintText: l10n?.habitEdit_habitName_hintText,
          hintStyle: TextStyle(color: colorData?.getColorContainer(colorType)),
          border: InputBorder.none,
        ),
        style: textTheme.headlineMedium?.copyWith(
          color: colorData?.getColor(colorType),
        ),
        keyboardType: TextInputType.text,
        onChanged: onNameChanged,
      );
    }

    Widget buildShowText(BuildContext context) {
      return DefaultTextStyle(
        style: textTheme.titleLarge!.copyWith(
          color: colorData?.getColor(colorType),
        ),
        overflow: TextOverflow.ellipsis,
        child: Text(name),
      );
    }

    return SliverAppBar.large(
      pinned: true,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: themeData.colorScheme.shadow,
      flexibleSpace: HabitFormFlexibleSpaceBar(
        collapsedTitle: buildShowText(context),
        expandedTitle: buildInputForm(context),
      ),
      automaticallyImplyLeading: false,
      leading: PageBackButton(
        reason:
            showInFullscreenDialog ? PageBackReason.close : PageBackReason.back,
        color: colorData?.getColor(colorType),
      ),
      actions: [
        AnimatedOpacity(
          opacity: showSaveButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: TextButton(
            onPressed: onSaveButtonPressed,
            child: Text(
              l10n?.habitEdit_saveButton_text ?? "Save",
              style: TextStyle(color: colorData?.getColor(colorType)),
            ),
          ),
        ),
      ],
    );
  }
}
