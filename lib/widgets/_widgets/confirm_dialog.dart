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

import '../../l10n/localizations.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  Widget? title,
  Widget? subtitle,
  Widget? cancelText,
  Widget? confirmText,
  WidgetBuilder? titleBuilder,
  WidgetBuilder? subtitleBuilder,
  WidgetBuilder? cancelTextBuilder,
  WidgetBuilder? confirmTextBuilder,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDialog(
      title: titleBuilder?.call(context) ?? title,
      subtitle: subtitleBuilder?.call(context) ?? subtitle,
      cancelText: cancelTextBuilder?.call(context) ?? cancelText,
      confirmText: confirmTextBuilder?.call(context) ?? confirmText,
    ),
  );
}

enum NormalizeConfirmDialogType { confirm, save, exit, delete }

Future<bool?> showNormalizedConfirmDialog({
  required BuildContext context,
  Widget? title,
  Widget? subtitle,
  Widget Function(BuildContext context, [L10n? l10n])? titleBuilder,
  Widget Function(BuildContext context, [L10n? l10n])? subtitleBuilder,
  NormalizeConfirmDialogType type = NormalizeConfirmDialogType.confirm,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = L10n.of(context);
      return ConfirmDialog(
        title: titleBuilder?.call(context, l10n) ?? title,
        subtitle: subtitleBuilder?.call(context, l10n) ?? subtitle,
        confirmText: l10n != null
            ? Text(l10n.confirmDialog_confirm_text(type.name))
            : null,
        cancelText: l10n != null ? Text(l10n.confirmDialog_cancel_text) : null,
      );
    },
  );
}

class ConfirmDialog extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? cancelText;
  final Widget? confirmText;

  const ConfirmDialog({
    super.key,
    this.title,
    this.subtitle,
    this.cancelText,
    this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: subtitle,
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () {
              Navigator.maybePop(context, false);
            },
            child: cancelText!,
          ),
        if (confirmText != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: confirmText!,
          ),
      ],
    );
  }
}
