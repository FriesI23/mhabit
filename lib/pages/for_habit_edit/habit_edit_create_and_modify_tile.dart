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

import '../../l10n/localizations.dart';

class HabitEditCreateAndModifyTile extends StatelessWidget {
  final DateTime createT;
  final DateTime modifyT;

  const HabitEditCreateAndModifyTile({
    super.key,
    required this.createT,
    required this.modifyT,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final textTheme = themeData.textTheme;
    final l10n = L10n.of(context);

    return ListTile(
      leading: Icon(Icons.info_outline, color: colorScheme.outline),
      title: Text.rich(
        TextSpan(
          text: l10n?.habitEdit_create_datetime_prefix,
          style: textTheme.bodyLarge,
          children: <TextSpan>[
            TextSpan(
              text: DateFormat.yMd(l10n?.localeName).add_Hms().format(createT),
            ),
          ],
        ),
      ),
      subtitle: Text.rich(
        TextSpan(
          text: l10n?.habitEdit_modify_datetime_prefix,
          style: textTheme.bodyLarge,
          children: <TextSpan>[
            TextSpan(
              text: DateFormat.yMd(l10n?.localeName).add_Hms().format(modifyT),
            ),
          ],
        ),
      ),
    );
  }
}
