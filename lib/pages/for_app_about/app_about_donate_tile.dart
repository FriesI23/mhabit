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

import '../../l10n/localizations.dart';
import '../../theme/icon.dart';
import '_widget.dart';

class AppAboutDonateTile extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppAboutDonateTile({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    return ListTile(
      leading: const SizedBox(
        height: kAppAboutListTileLeadingHeight,
        width: kAppAboutListTileLeadingWidth,
        child: Icon(CommonIcons.la_donate),
      ),
      title: l10n != null
          ? Text(l10n.appAbout_donateTile_titleText)
          : const Text("Donate"),
      subtitle: l10n != null
          ? Text(l10n.appAbout_donateTile_subTitleText)
          : const Text("null"),
      onTap: onPressed,
    );
  }
}
