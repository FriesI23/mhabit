// Copyright 2026 Fries_I23
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

import 'package:flutter/material.dart';

import '../../../assets/assets.gen.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../models/thirdparty_import.dart';
import '../../../providers/workflow/thirdparty_file_importer.dart';
import '../../../widgets/widgets.dart';

/// Return an icon widget for the given [ThirdPartyProvider].
Widget _providerIcon(ThirdPartyProvider provider) {
  return switch (provider) {
    ThirdPartyProvider.loopHabitTracker => CircleAvatar(
      backgroundImage: Assets.icons.uhabitIcon.provider(),
    ),
  };
}

/// Return the localized display name for a [ThirdPartyProvider].
String _providerDisplayName(ThirdPartyProvider provider, L10n? l10n) {
  return switch (provider) {
    ThirdPartyProvider.loopHabitTracker =>
      l10n?.appSetting_thirdPartyImport_provider_loopName ??
          'Loop Habit Tracker',
  };
}

/// Build the version subtitle widget where only the version ("vX.Y.Z") is a
/// clickable link. The l10n string uses "\<ver/\>" as a placeholder that
/// gets replaced by the tappable version label.
Widget _buildProviderVersionTile(
  ThirdPartyProvider provider,
  L10n? l10n,
  BuildContext context,
) {
  final importerVersion = getThirdPartyImporterVersion(provider);

  const kMarker = '<ver/>';
  final template =
      l10n?.appSetting_thirdPartyImport_provider_versionHint ??
      'Supports CSV (tested up to $kMarker)';
  final parts = template.split(kMarker);

  final versionLabel = 'v${importerVersion.version}';
  final baseStyle = Theme.of(context).textTheme.bodySmall;
  final linkStyle = baseStyle?.copyWith(
    decoration: TextDecoration.underline,
    color: Theme.of(context).colorScheme.primary,
  );

  return _VersionHintText(
    leadingText: parts.first,
    trailingText: parts.length > 1 ? parts.sublist(1).join(kMarker) : null,
    versionLabel: versionLabel,
    versionUrl: importerVersion.releaseUrl,
    baseStyle: baseStyle,
    linkStyle: linkStyle,
  );
}

class _VersionHintText extends StatelessWidget {
  final String leadingText;
  final String? trailingText;
  final String versionLabel;
  final Uri versionUrl;
  final TextStyle? baseStyle;
  final TextStyle? linkStyle;

  const _VersionHintText({
    required this.leadingText,
    required this.trailingText,
    required this.versionLabel,
    required this.versionUrl,
    required this.baseStyle,
    required this.linkStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: leadingText),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: InkWell(
              onTap: () => launchExternalUrl(versionUrl),
              child: Text(versionLabel, style: linkStyle),
            ),
          ),
          if (trailingText != null) TextSpan(text: trailingText),
        ],
      ),
    );
  }
}

/// Show a dialog that lets the user pick a third-party import source.
///
/// Returns the selected [ThirdPartyProvider], or `null` if the user cancelled.
Future<ThirdPartyProvider?> showThirdPartyImportProviderDialog(
  BuildContext context,
) async {
  return showDialog<ThirdPartyProvider>(
    context: context,
    builder: (context) => const _ThirdPartyImportProviderDialog(),
  );
}

class _ThirdPartyImportProviderDialog extends StatelessWidget {
  const _ThirdPartyImportProviderDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThirdPartyProvider.values.map((provider) {
            return L10nBuilder(
              builder: (context, l10n) => ListTile(
                contentPadding: const EdgeInsets.only(left: 8.0, right: 8.0),
                leading: _providerIcon(provider),
                title: Text(_providerDisplayName(provider, l10n)),
                subtitle: _buildProviderVersionTile(provider, l10n, context),
                onTap: () => Navigator.of(context).pop(provider),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
