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

import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';
import '../styles.dart';

class AppAboutLicenseTile extends StatefulWidget {
  const AppAboutLicenseTile({super.key});

  @override
  State<AppAboutLicenseTile> createState() => _AppAboutLicenseTileState();
}

class _AppAboutLicenseTileState extends State<AppAboutLicenseTile> {
  void onPressed() async {
    final licenseText = await rootBundle.loadString('LICENSE');
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => L10nBuilder(
        builder: (context, l10n) => AlertDialog(
          content: Scrollbar(
            child: SingleChildScrollView(
              primary: true,
              scrollDirection: Axis.vertical,
              child: ThematicMarkdownBlock(data: "```text\n$licenseText\n```"),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      leading: const SizedBox(
        height: kAppAboutListTileLeadingHeight,
        width: kAppAboutListTileLeadingWidth,
        child: Icon(Icons.balance_outlined),
      ),
      title: l10n != null
          ? Text(l10n.appAbout_licenseTile_titleText)
          : const Text("License"),
      subtitle: l10n != null
          ? Text(l10n.appAbout_licenseTile_subtitleText)
          : const Text("Unknown"),
      onTap: onPressed,
    );
  }
}
