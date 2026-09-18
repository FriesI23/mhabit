// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/custom_date_format.dart';
import '../../../providers/app_ui/app_custom_date_format.dart';
import '../../../utils/app_clock.dart';

class AppDateFormatPreview extends StatefulWidget {
  const AppDateFormatPreview({super.key});

  @override
  State<AppDateFormatPreview> createState() => _AppDateFormatPreviewState();
}

class _AppDateFormatPreviewState extends State<AppDateFormatPreview> {
  late DateTime _previewDateTime;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _previewDateTime = AppClock().now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _previewDateTime = AppClock().now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context
        .select<AppCustomDateYmdHmsConfigViewModel, CustomDateYmdHmsConfig>(
          (vm) => vm.config,
        );
    final l10n = L10n.of(context);
    final formatter = config.getFormatter(l10n?.localeName);
    return AdaptiveListSection(
      header: Text(l10n?.appDateFormat_preview_text ?? 'Preview'),
      children: [
        AdaptiveListTile(
          key: const ValueKey('date-format-preview'),
          title: Text(
            formatter.format(_previewDateTime),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(formatter.pattern ?? ''),
        ),
      ],
    );
  }
}
