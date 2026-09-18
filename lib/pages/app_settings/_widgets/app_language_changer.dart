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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../common/consts.dart';
import '../../../l10n/localizations.dart';

Future<AppLanguageChangerDialogResult?> showAppLanguageChangerDialog({
  required BuildContext context,
  required Locale? selectedLocale,
}) => showAdaptiveSheet<AppLanguageChangerDialogResult>(
  context: context,
  builder: (_) => AppLanguageChangerDialog(selectedLocale: selectedLocale),
);

class AppLanguageChangerDialogResult {
  final Locale? choosenLanguage;

  const AppLanguageChangerDialogResult({this.choosenLanguage});
}

class AppLanguageChangerDialog extends StatelessWidget {
  final Locale? selectedLocale;

  const AppLanguageChangerDialog({super.key, required this.selectedLocale});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final systemLocale = View.of(context).platformDispatcher.locale;
    final systemLocaleScriptName = L10n.delegate.isSupported(systemLocale)
        ? lookupL10n(systemLocale).localeScriptName
        : '';
    final systemLabel = systemLocaleScriptName.isEmpty
        ? l10n?.appSetting_changeLanguage_followSystem_noLocale_text ??
              'Follow System'
        : l10n?.appSetting_changeLanguage_followSystem_text(
                systemLocaleScriptName,
              ) ??
              'Follow System ($systemLocaleScriptName)';
    final options = <({Locale? locale, String label})>[
      (locale: null, label: systemLabel),
      for (final locale in appSupportedLocales.sorted(
        (a, b) => a.toString().compareTo(b.toString()),
      ))
        (locale: locale, label: lookupL10n(locale).localeScriptName),
    ];

    final currentLanguage = selectedLocale == null
        ? systemLabel
        : lookupL10n(selectedLocale!).localeScriptName;

    return AdaptiveModal(
      size: const AdaptiveModalSize.constrained(),
      title: l10n != null
          ? Text(l10n.appSetting_changeLanguageDialog_titleText)
          : null,
      body: AdaptiveListSection(
        padding: EdgeInsets.zero,
        header: Text(
          l10n?.appSetting_changeLanguageDialog_currentLanguage_text(
                currentLanguage,
              ) ??
              'Current language: $currentLanguage',
        ),
        children: [
          for (final option in options)
            Semantics(
              key: ValueKey('language-option-${option.locale ?? 'system'}'),
              selected: selectedLocale == option.locale,
              child: _LanguageOption(
                label: option.label,
                selected: selectedLocale == option.locale,
                onTap: () => Navigator.of(context).pop(
                  AppLanguageChangerDialogResult(
                    choosenLanguage: option.locale,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AdaptiveListTile(
    title: Text(label),
    trailing: selected ? const AdaptiveCheckmark() : null,
    onTap: onTap,
  );
}
