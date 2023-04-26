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
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../common/app_info.dart';
import '../../component/widget.dart';
import '../../l10n/localizations.dart';
import '_widget.dart';

class AppAboutVersionTile extends StatefulWidget {
  final String logoPath;
  final String changeLogPath;

  const AppAboutVersionTile({
    super.key,
    required this.logoPath,
    required this.changeLogPath,
  });

  @override
  State<AppAboutVersionTile> createState() => _AppAboutVersionTileState();
}

class _AppAboutVersionTileState extends State<AppAboutVersionTile> {
  void onLongPressed() async {
    final text = await rootBundle.loadString(
        L10n.of(context)?.appAbout_verionTile_changeLogPath ??
            widget.changeLogPath);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => L10nBuilder(
        builder: (context, l10n) => AlertDialog(
          content: RawScrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: MarkdownBody(
                data: text,
                listItemCrossAxisAlignment:
                    MarkdownListItemCrossAxisAlignment.start,
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
      leading: SvgTemplateImage(
        size: kAppAboutListTileLeadingSize,
        label: 'app-about-verion-tile-logo',
        svgTemplatePath: widget.logoPath,
      ),
      title: Text(l10n?.appName ?? AppInfo().appName),
      subtitle: Text(
          l10n?.appAbout_verionTile_titleText(AppInfo().appVersion) ??
              "Version: ${AppInfo().appVersion}"),
      onLongPress: onLongPressed,
    );
  }
}
