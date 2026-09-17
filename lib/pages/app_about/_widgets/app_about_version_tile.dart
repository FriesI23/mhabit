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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../common/app_info.dart';
import '../../../extensions/asset_bundle_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';
import '../../app_changelog/changelog_dialog.dart';
import '../../app_changelog/changelog_parser.dart';
import '../styles.dart';

class AppAboutVersionTile extends StatefulWidget {
  final bool isMonoLogo;
  final String logoPath;
  final String changeLogPath;

  const AppAboutVersionTile({
    super.key,
    this.isMonoLogo = false,
    required this.logoPath,
    required this.changeLogPath,
  });

  @override
  State<AppAboutVersionTile> createState() => _AppAboutVersionTileState();
}

class _AppAboutVersionTileState extends State<AppAboutVersionTile> {
  void onLongPressed() async {
    final path =
        L10n.of(context)?.appAbout_versionTile_changeLogPath ??
        widget.changeLogPath;
    final content = await rootBundle.loadChangelog(path);
    if (!mounted) return;

    final version = AppInfo().changelogVersion;
    final section = extractVersionSectionWithFallback(
      content,
      version,
      useLatestFallback: true,
    );
    final fullChangelog = stripChangelogPreamble(content);

    if (!mounted) return;
    await showChangelogDialog(
      context: context,
      currentVersionSection: section ?? fullChangelog,
      fullChangelog: fullChangelog,
      version: version,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final colorFilter = widget.isMonoLogo
        ? ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          )
        : null;
    final leading = SvgTemplateImage(
      size: kAppAboutListTileLeadingSize,
      label: 'app-about-verion-tile-logo',
      svgTemplatePath: widget.logoPath,
      colorFilter: colorFilter,
    );
    final title = Text(l10n?.appName ?? AppInfo().appName);
    final subtitle = Text(
      l10n?.appAbout_versionTile_titleText(AppInfo().appVersion) ??
          "Version: ${AppInfo().appVersion}",
    );
    // This informational row deliberately keeps its long-press-only action.
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        onLongPress: onLongPressed,
      ),
      AdaptiveStyle.apple => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: onLongPressed,
        child: AdaptiveListTile.apple(
          leading: leading,
          title: title,
          subtitle: subtitle,
        ),
      ),
    };
  }
}
