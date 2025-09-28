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

import '../common/global.dart';
import '../l10n/localizations.dart';

class BuildWidgetHelper {
  static final BuildWidgetHelper _singleton = BuildWidgetHelper._internal();

  factory BuildWidgetHelper() {
    return _singleton;
  }

  BuildWidgetHelper._internal();

  SnackBar buildSnackBarWithUndo(
    BuildContext context, {
    required Widget content,
    String? label,
    Duration? showDuration,
    required VoidCallback onPressed,
  }) {
    final action = SnackBarAction(
      label: label ?? L10n.of(context)?.snackbar_undoText ?? 'undo',
      onPressed: onPressed,
    );
    if (showDuration == null) return SnackBar(content: content, action: action);
    return SnackBar(content: content, duration: showDuration, action: action);
  }

  SnackBar buildSnackBarWithDismiss(
    BuildContext context, {
    required Widget content,
    String? label,
    Duration? duration,
    VoidCallback? onPressed,
  }) {
    return SnackBar(
      content: content,
      duration: duration ?? const Duration(milliseconds: 2000),
      action: SnackBarAction(
        label: label ?? L10n.of(context)?.snackbar_dismissText ?? 'dismiss',
        onPressed:
            onPressed ?? () => snackbarKey.currentState?.hideCurrentSnackBar(),
      ),
    );
  }
}
