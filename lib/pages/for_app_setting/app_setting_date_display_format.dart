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

import '../../model/custom_date_format.dart';
import '../../widgets/widgets.dart';

class AppSettingDateDisplayFormatListTile extends StatelessWidget {
  final CustomDateYmdHmsConfig config;
  final VoidCallback? onPressed;

  const AppSettingDateDisplayFormatListTile({
    super.key,
    required this.config,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return L10nBuilder(
      builder: (context, l10n) {
        final patternText = config.useSystemFormat
            ? l10n?.appSetting_dateDisplayFormat_titleTemplate_followSystemText
            : config.getFormatter(l10n?.localeName).pattern;
        return ListTile(
          title: Text(
              l10n?.appSetting_dateDisplayFormat_titleText(patternText ?? '') ??
                  "Date display format ($patternText)"),
          subtitle: l10n != null
              ? Text(l10n.appSetting_dateDisplayFormat_subTitleText)
              : null,
          onTap: onPressed,
        );
      },
    );
  }
}
