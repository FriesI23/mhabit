// Copyright 2025 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';
import '../styles.dart';

class AppAboutPrivacyTile extends StatefulWidget {
  final String privacyPath;

  const AppAboutPrivacyTile({super.key, this.privacyPath = "PRIVACY.md"});

  @override
  State<AppAboutPrivacyTile> createState() => _AppAboutPrivacyTile();
}

class _AppAboutPrivacyTile extends State<AppAboutPrivacyTile> {
  static const _tableMinScrollMinWidth = 800.0;
  static const _tableMinScrollMaxWidth = 1000.0;

  TableConfig _buildTableConfig() => TableConfig(
        wrapper: (child) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Builder(
            builder: (context) => ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: clampDouble(MediaQuery.sizeOf(context).width,
                            _tableMinScrollMinWidth, _tableMinScrollMaxWidth) -
                        200),
                child: child),
          ),
        ),
      );

  void _onPressed() async {
    final text = await rootBundle.loadString(widget.privacyPath);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Scrollbar(
          child: SingleChildScrollView(
            primary: true,
            scrollDirection: Axis.vertical,
            child: ThematicMarkdownBlock(
              data: text,
              configBuilder: (config) => config.copy(configs: [
                _buildTableConfig(),
              ]),
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
        child: Icon(MdiIcons.shieldLockOutline),
      ),
      title: l10n != null
          ? Text(l10n.appAbout_privacyTile_titleText)
          : const Text("Privacy"),
      subtitle:
          l10n != null ? Text(l10n.appAbout_privacyTile_subTitleText) : null,
      onTap: _onPressed,
    );
  }
}
