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

import '../../common/logging.dart';
import '../../common/utils.dart';
import '../../l10n/localizations.dart';
import '../../model/about_info.dart';
import '_widget.dart';

class AppAboutIssueTrackerTile extends StatefulWidget {
  final String? url;

  const AppAboutIssueTrackerTile({super.key, this.url});

  @override
  State<AppAboutIssueTrackerTile> createState() =>
      _AppAboutIssueTrackerTileState();
}

class _AppAboutIssueTrackerTileState extends State<AppAboutIssueTrackerTile> {
  void onPressed() async {
    final url = Uri.parse(context.read<AboutInfo>().issueTrackerUrl);
    if (await canLaunchUrl(url)) {
      await launchExternalUrl(url);
    } else {
      ErrorLog.openUrl("failed to open issue tracker url: $url");
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
          child: Icon(MdiIcons.bugOutline),
        ),
        title: l10n != null
            ? Text(l10n.appAbout_issueTrackerTile_titleText)
            : const Text("Issue tracker"),
        subtitle: Text(value.issueTrackerUrl),
        onTap: value.issueTrackerUrl.isNotEmpty ? onPressed : null,
      ),
    );
  }
}
