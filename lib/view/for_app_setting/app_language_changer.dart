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

import '../../common/consts.dart';
import '../../l10n/localizations.dart';

Future<AppLanguageChangerDialogResult?> showAppLanguageChangerDialog({
  required BuildContext context,
  required Locale? selectedLocale,
}) async {
  return showDialog<AppLanguageChangerDialogResult>(
    context: context,
    builder: (context) => AppLanguageChangerDialog(
      selectedLocale: selectedLocale,
    ),
  );
}

class AppLanguageChangerDialogResult {
  final Locale? choosenLanguage;

  const AppLanguageChangerDialogResult({this.choosenLanguage});
}

class AppLanguageChangerDialog extends StatelessWidget {
  final Locale? selectedLocale;

  const AppLanguageChangerDialog({super.key, required this.selectedLocale});

  @override
  Widget build(BuildContext context) {
    List<SimpleDialogOption> buildOptions(BuildContext context, [L10n? l10n]) {
      final systemLocale = View.of(context).platformDispatcher.locale;
      final systemLocaleScriptName = L10n.delegate.isSupported(systemLocale)
          ? lookupL10n(systemLocale).localeScriptName
          : "";
      final List<SimpleDialogOption> result = [
        SimpleDialogOption(
          onPressed: () =>
              Navigator.of(context).pop(const AppLanguageChangerDialogResult()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TODO(INDEV): l10n
              Text(systemLocaleScriptName.isEmpty
                  ? "Follow System"
                  : "Follow System ($systemLocaleScriptName)"),
              if (selectedLocale == null) const Icon(Icons.check),
            ],
          ),
        )
      ];
      for (var locale in appSupportedLocales
          .sorted((a, b) => a.toString().compareTo(b.toString()))) {
        result.add(SimpleDialogOption(
          onPressed: () => Navigator.of(context)
              .pop(AppLanguageChangerDialogResult(choosenLanguage: locale)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lookupL10n(locale).localeScriptName),
              if (selectedLocale == locale) const Icon(Icons.check),
            ],
          ),
        ));
      }
      return result;
    }

    final l10n = L10n.of(context);
    return SimpleDialog(
      // TODO(INDEV): l10n
      title: const Text("Select Language"),
      children: buildOptions(context, l10n),
    );
  }
}
