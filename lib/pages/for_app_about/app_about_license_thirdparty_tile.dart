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
import 'package:markdown_widget/markdown_widget.dart';

import '../../common/utils.dart';
import '../../l10n/localizations.dart';
import '../../widgets/widgets.dart';
import '_widget.dart';

class AppAboutThirdPartyLicenseTile extends StatefulWidget {
  const AppAboutThirdPartyLicenseTile({super.key});

  @override
  State<AppAboutThirdPartyLicenseTile> createState() =>
      _AppAboutThirdPartyLicenseTileState();
}

class _AppAboutThirdPartyLicenseTileState
    extends State<AppAboutThirdPartyLicenseTile> {
  void onPressed() async {
    final licenseText = await rootBundle.loadString('LICENSE_THIRDPARTY.md');
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => L10nBuilder(
        builder: (context, l10n) => AlertDialog(
          content: Scrollbar(
            child: SingleChildScrollView(
              primary: true,
              child: ThematicMarkdownBlock(
                data: licenseText,
                configBuilder: (config) => config.copy(configs: [
                  LinkConfig(
                      onTap: (href) => launchExternalUrl(Uri.parse(href))),
                ]),
              ),
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
        child: null,
      ),
      title: l10n != null
          ? Text(l10n.appAbout_licenseThirdPartyTile_titleText)
          : const Text("Third Party License"),
      subtitle: l10n != null
          ? Text(l10n.appAbout_licenseThirdPartyTile_subtitleText, maxLines: 1)
          : null,
      onTap: onPressed,
    );
  }
}
