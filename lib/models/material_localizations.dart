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

import 'package:flutter/material.dart';

import '../annotations/proxy_annotation.dart';

part 'material_localizations.g.dart';

@Proxy(MaterialLocalizations)
class MaterialLocalizatiosProxy extends _$MaterialLocalizationsProxy {
  late final int? _customFirstDayOfWeekIndex;

  MaterialLocalizatiosProxy(super._base, {int? firstDayOfWeekIndex}) {
    if (firstDayOfWeekIndex != null) {
      assert(
        firstDayOfWeekIndex >= 0 && firstDayOfWeekIndex < narrowWeekdays.length,
      );
    }
    _customFirstDayOfWeekIndex = firstDayOfWeekIndex?.clamp(
      0,
      narrowWeekdays.length - 1,
    );
  }

  static LocalizationsDelegate<MaterialLocalizations> delegateProxyOf(
    LocalizationsDelegate<MaterialLocalizations> delegate, {
    Map<String, dynamic>? overrides,
  }) => _MaterialLocalizatiosProxyDelegate(delegate, overrides ?? {});

  @override
  int get firstDayOfWeekIndex =>
      _customFirstDayOfWeekIndex ?? super.firstDayOfWeekIndex;
}

class _MaterialLocalizatiosProxyDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  final Map<String, dynamic> overrides;

  final LocalizationsDelegate<MaterialLocalizations> base;

  const _MaterialLocalizatiosProxyDelegate(this.base, this.overrides);

  @override
  bool isSupported(Locale locale) => base.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) => base
      .load(locale)
      .then(
        (value) => MaterialLocalizatiosProxy(
          value,
          firstDayOfWeekIndex: overrides['firstDayOfWeekIndex'],
        ),
      );

  @override
  bool shouldReload(_MaterialLocalizatiosProxyDelegate old) =>
      base.shouldReload(old);
}
