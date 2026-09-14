// Copyright 2026 Fries_I23
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

import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../l10n/localizations.dart';

/// Returns true for confirm, false for cancel, and null for external dismissal.
Future<bool?> showAdaptiveConfirmDialog({
  required BuildContext context,
  Widget? title,
  Widget? content,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructiveAction = false,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final l10n = L10n.of(context);
  return showAdaptiveModalDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (_) => AdaptiveConfirmDialog(
      title: title,
      content: content,
      confirmLabel: confirmLabel ?? l10n?.confirmDialog_confirm_text('confirm'),
      cancelLabel: cancelLabel ?? l10n?.confirmDialog_cancel_text,
      isDestructiveAction: isDestructiveAction,
    ),
  );
}

/// Submits a choice once; business operations remain with the caller.
class AdaptiveConfirmDialog extends StatefulWidget {
  const AdaptiveConfirmDialog({
    super.key,
    this.title,
    this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructiveAction = false,
  });

  final Widget? title;
  final Widget? content;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool isDestructiveAction;

  @override
  State<AdaptiveConfirmDialog> createState() => _AdaptiveConfirmDialogState();
}

class _AdaptiveConfirmDialogState extends State<AdaptiveConfirmDialog> {
  bool _submitted = false;

  void _submit(bool result) {
    if (!mounted || _submitted || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    _submitted = true;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveDialog(
      title: widget.title,
      content: widget.content,
      actions: [
        AdaptiveDialogAction(
          label:
              widget.cancelLabel ?? l10n?.confirmDialog_cancel_text ?? 'Cancel',
          onPressed: () => _submit(false),
        ),
        AdaptiveDialogAction(
          label:
              widget.confirmLabel ??
              l10n?.confirmDialog_confirm_text('confirm') ??
              'Confirm',
          isDefaultAction: !widget.isDestructiveAction,
          isDestructiveAction: widget.isDestructiveAction,
          onPressed: () => _submit(true),
        ),
      ],
    );
  }
}
