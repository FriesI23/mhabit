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

import '../../../extension/colorscheme_extensions.dart';
import '../../../l10n/localizations.dart';

class HabitEditDescTile extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onDescChanged;

  const HabitEditDescTile({
    super.key,
    required this.controller,
    this.onDescChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    return ListTile(
      leading: Icon(Icons.notes, color: colorScheme.outline),
      title: TextField(
        controller: controller,
        decoration: InputDecoration.collapsed(
            hintText: l10n?.habitEdit_desc_hintText,
            hintStyle: TextStyle(color: colorScheme.outlineOpacity64),
            border: InputBorder.none),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        style: textTheme.bodyLarge,
        onChanged: onDescChanged,
      ),
      titleAlignment: ListTileTitleAlignment.titleHeight,
    );
  }
}
