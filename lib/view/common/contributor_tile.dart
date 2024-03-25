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

import 'package:flutter/material.dart';
import 'package:intl/locale.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/utils.dart';
import '../../component/widget.dart';
import '../../extension/locale_exntensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../logging/logger_stack.dart';
import '../../model/contributor.dart';

class ContributorTile extends StatelessWidget {
  final Contributors contributors;
  final Widget? Function(Locale? l)? leadingBuilder;

  const ContributorTile(
      {super.key, required this.contributors, this.leadingBuilder});

  @override
  Widget build(BuildContext context) {
    Widget buildContributorCell(BuildContext context, ContributorInfo info) {
      final url = info.url != null ? Uri.parse(info.url!) : null;
      if (url != null) {
        return InkWell(
          onTap: () async {
            if (await canLaunchUrl(url)) {
              await launchExternalUrl(url);
            } else {
              appLog.network.error("$this",
                  ex: ["failed to open url", info],
                  stackTrace: LoggerStackTrace.from(StackTrace.current));
            }
          },
          child: Text(
            info.name,
            style: const TextStyle(
                decoration: TextDecoration.underline, color: Colors.blue),
          ),
        );
      }
      return Text(info.name);
    }

    Iterable<Widget> buildContributor(BuildContext context,
        [L10n? l10n]) sync* {
      final cs = contributors.getContributors();
      if (cs.isEmpty) return;
      yield GroupTitleListTile(
          title: Text(l10n?.contributors_tile_title ?? "Contributors"));
      yield ListTile(
        visualDensity: VisualDensity.compact,
        leading: leadingBuilder?.call(null),
        title: Wrap(
            spacing: 12,
            children: cs.map((e) => buildContributorCell(context, e)).toList()),
      );
    }

    Iterable<Widget> buildTranslation(BuildContext context, Locale locale,
        [L10n? l10n]) sync* {
      final cs = contributors.getTranslations(locale);
      if (cs == null || cs.isEmpty) return;
      try {
        yield GroupTitleListTile(
            title: Text(lookupL10n(locale.toLocale()).localeScriptName));
      } on FlutterError catch (e) {
        appLog.l10n.warn(context,
            widget: this, ex: ["lockup l10n failed", locale], error: e);
        yield GroupTitleListTile(title: Text(locale.toString()));
      }

      yield ListTile(
        visualDensity: VisualDensity.compact,
        leading: leadingBuilder?.call(locale),
        title: Wrap(
            spacing: 12,
            children: cs.map((e) => buildContributorCell(context, e)).toList()),
      );
    }

    return L10nBuilder(
      builder: (context, l10n) => Column(
        children: [
          ...buildContributor(context, l10n),
          for (var locale in contributors.locales)
            ...buildTranslation(context, locale, l10n),
        ],
      ),
    );
  }
}
