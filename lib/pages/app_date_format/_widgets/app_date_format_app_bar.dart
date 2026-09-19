// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../l10n/localizations.dart';

class AppDateFormatAppBar extends StatelessWidget {
  const AppDateFormatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveSliverAppBar(
      height: AdaptiveStyle.of(context).appToolbarHeight,
      leading: const AdaptiveBackButton(type: AdaptiveBackButtonType.back),
      title: Text(
        l10n?.common_customDateTimeFormatPicker_fmtTileText ?? 'Date format',
      ),
    );
  }
}
