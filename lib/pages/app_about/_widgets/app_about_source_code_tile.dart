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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../logging/helper.dart';
import '../../../logging/logger_stack.dart';
import '../../../providers/about_info.dart';
import '../styles.dart';

class AppAboutSourceCodeTile extends StatefulWidget {
  final String? url;

  const AppAboutSourceCodeTile({super.key, this.url});

  @override
  State<AppAboutSourceCodeTile> createState() => _AppAboutSourceCodeTileState();
}

class _AppAboutSourceCodeTileState extends State<AppAboutSourceCodeTile> {
  void onPressed() async {
    final url = Uri.parse(context.read<AboutInfo>().sourceCodeUrl);
    if (await canLaunchUrl(url)) {
      await launchExternalUrl(url);
    } else {
      appLog.network.error("$widget.onPressed",
          ex: ["failed to open source code url", url],
          stackTrace: LoggerStackTrace.from(StackTrace.current));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Consumer<AboutInfo>(
      builder: (context, value, child) => ListTile(
        leading: const SizedBox(
          height: kAppAboutListTileLeadingHeight,
          width: kAppAboutListTileLeadingWidth,
          child: Icon(MdiIcons.sourceBranch),
        ),
        title: l10n != null
            ? Text(l10n.appAbout_sourceCodeTile_titleText)
            : const Text("Source code"),
        subtitle: Text(value.sourceCodeUrl),
        onTap: value.sourceCodeUrl.isNotEmpty ? onPressed : null,
      ),
    );
  }
}
