// Copyright 2024 Fries_I23
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

import 'package:adaptive_actions/cupertino.dart' show AdaptiveCupertinoTooltip;
import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoTheme;
import 'package:flutter/material.dart';
import 'package:intl/locale.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/utils.dart';
import '../../../extensions/locale_exntensions.dart';
import '../../../l10n/localizations.dart';
import '../../../logging/helper.dart';
import '../../../logging/logger_stack.dart';
import '../../../models/contributor.dart';
import '../../../widgets/widgets.dart';

class ContributorTile extends StatelessWidget {
  final Contributors contributors;
  final Widget? Function(Locale? l)? leadingBuilder;

  const ContributorTile({
    super.key,
    required this.contributors,
    this.leadingBuilder,
  });

  String _translationTitle(BuildContext context, Locale locale) {
    try {
      return lookupL10n(locale.toLocale()).localeScriptName;
    } on FlutterError catch (e) {
      appLog.l10n.warn(
        context,
        widget: this,
        ex: ["lookup l10n failed", locale],
        error: e,
      );
      return locale.toString();
    }
  }

  Widget _buildSection(
    String title,
    Iterable<ContributorInfo> names,
    Locale? locale,
  ) {
    if (names.isEmpty) return const SizedBox.shrink();
    final leading = leadingBuilder?.call(locale);
    return AdaptiveListSection(
      header: Text(title),
      hasLeading: leading != null,
      children: [
        AdaptiveListTile(
          leading: leading,
          title: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [for (final info in names) _ContributorName(info: info)],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => L10nBuilder(
    builder: (context, l10n) => Column(
      children: [
        _buildSection(
          l10n?.contributors_tile_title ?? "Contributors",
          contributors.getContributors(),
          null,
        ),
        for (final locale in contributors.locales)
          if (contributors.getTranslations(locale) case final names?)
            if (names.isNotEmpty)
              _buildSection(_translationTitle(context, locale), names, locale),
      ],
    ),
  );
}

class _ContributorName extends StatelessWidget {
  const _ContributorName({required this.info});

  final ContributorInfo info;

  Future<void> _openUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchExternalUrl(url);
    } else {
      appLog.network.error(
        "$this",
        ex: ["failed to open url", info],
        stackTrace: LoggerStackTrace.from(StackTrace.current),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = AdaptiveStyle.of(context);
    final url = info.url != null ? Uri.parse(info.url!) : null;
    final text = Text(
      "@${info.name}",
      style: url == null
          ? null
          : TextStyle(
              decoration: TextDecoration.underline,
              color: switch (style) {
                AdaptiveStyle.material => Theme.of(context).colorScheme.primary,
                AdaptiveStyle.apple => CupertinoTheme.of(context).primaryColor,
              },
            ),
    );
    const padding = EdgeInsets.symmetric(vertical: 4);
    final Widget name = url == null
        ? Padding(padding: padding, child: text)
        : Semantics(
            link: true,
            child: switch (style) {
              AdaptiveStyle.material => InkWell(
                onTap: () => _openUrl(url),
                child: Padding(padding: padding, child: text),
              ),
              AdaptiveStyle.apple => CupertinoButton(
                padding: padding,
                minimumSize: Size.zero,
                onPressed: () => _openUrl(url),
                child: text,
              ),
            },
          );
    final comment = info.comment;
    if (comment == null || comment.isEmpty) return name;
    return switch (style) {
      AdaptiveStyle.material => Tooltip(message: comment, child: name),
      AdaptiveStyle.apple => AdaptiveCupertinoTooltip(
        message: comment,
        child: name,
      ),
    };
  }
}
