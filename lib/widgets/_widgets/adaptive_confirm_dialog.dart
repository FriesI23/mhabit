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

import 'package:flutter/cupertino.dart' show CupertinoCheckbox;
import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../l10n/localizations.dart';

/// Returns true for confirm, false for cancel, and null for external dismissal.
///
/// Providing [onSkipConfirmed] enables the optional "don't ask again" choice.
/// It receives the skip value once on confirmation, never on cancellation.
/// Capture the value here; apply business changes after awaiting the dialog.
Future<bool?> showAdaptiveConfirmDialog({
  required BuildContext context,
  Widget? title,
  Widget? content,
  String? confirmLabel,
  String? cancelLabel,
  bool isDestructiveAction = false,
  ValueChanged<bool>? onSkipConfirmed,
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
      onSkipConfirmed: onSkipConfirmed,
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
    this.onSkipConfirmed,
  });

  final Widget? title;
  final Widget? content;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool isDestructiveAction;

  /// Enables the skip choice and reports its value only when confirmed.
  final ValueChanged<bool>? onSkipConfirmed;

  @override
  State<AdaptiveConfirmDialog> createState() => _AdaptiveConfirmDialogState();
}

class _AdaptiveConfirmDialogState extends State<AdaptiveConfirmDialog> {
  bool _skip = false;
  bool _submitted = false;

  void _submit(bool result, {bool skip = false}) {
    if (!mounted || _submitted || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    _submitted = true;
    Navigator.of(context).pop(result);
    if (result) widget.onSkipConfirmed?.call(skip);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final confirmLabel =
        widget.confirmLabel ??
        l10n?.confirmDialog_confirm_text('confirm') ??
        'Confirm';
    final cancelLabel =
        widget.cancelLabel ?? l10n?.confirmDialog_cancel_text ?? 'Cancel';
    return switch (AdaptiveStyle.of(context)) {
      AdaptiveStyle.material => _MaterialConfirmDialog(
        title: widget.title,
        content: widget.content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructiveAction: widget.isDestructiveAction,
        skip: _skip,
        onSkipChanged: widget.onSkipConfirmed == null
            ? null
            : (value) => setState(() => _skip = value),
        onConfirm: (skip) => _submit(true, skip: skip),
        onCancel: () => _submit(false),
      ),
      AdaptiveStyle.apple => _CupertinoConfirmDialog(
        title: widget.title,
        content: widget.content,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructiveAction: widget.isDestructiveAction,
        skip: _skip,
        onSkipChanged: widget.onSkipConfirmed == null
            ? null
            : (value) => setState(() => _skip = value),
        onConfirm: (skip) => _submit(true, skip: skip),
        onCancel: () => _submit(false),
      ),
    };
  }
}

class _MaterialConfirmDialog extends StatelessWidget {
  const _MaterialConfirmDialog({
    this.title,
    this.content,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructiveAction,
    required this.skip,
    required this.onSkipChanged,
    required this.onConfirm,
    required this.onCancel,
  });

  final Widget? title;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructiveAction;
  final bool skip;
  final ValueChanged<bool>? onSkipChanged;
  final ValueChanged<bool> onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => MaterialAdaptiveDialog(
    title: title,
    content: onSkipChanged == null
        ? content
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?content,
              CheckboxListTile(
                value: skip,
                onChanged: (value) => onSkipChanged!(value ?? false),
                title: Text(
                  L10n.of(context)?.common_dontShowAgain ?? "Don't show again",
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
    actions: [
      AdaptiveDialogAction(label: cancelLabel, onPressed: onCancel),
      AdaptiveDialogAction(
        label: confirmLabel,
        isDefaultAction: !isDestructiveAction,
        isDestructiveAction: isDestructiveAction,
        onPressed: () => onConfirm(onSkipChanged != null && skip),
      ),
    ],
  );
}

class _CupertinoConfirmDialog extends StatelessWidget {
  const _CupertinoConfirmDialog({
    this.title,
    this.content,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructiveAction,
    required this.skip,
    required this.onSkipChanged,
    required this.onConfirm,
    required this.onCancel,
  });

  final Widget? title;
  final Widget? content;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructiveAction;
  final bool skip;
  final ValueChanged<bool>? onSkipChanged;
  final ValueChanged<bool> onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final useSkipAction = Theme.of(context).platform == TargetPlatform.iOS;
    final hasSkip = onSkipChanged != null;
    final cancelAction = AdaptiveDialogAction(
      label: cancelLabel,
      onPressed: onCancel,
    );
    final confirmAction = AdaptiveDialogAction(
      label: confirmLabel,
      isDefaultAction: !isDestructiveAction,
      isDestructiveAction: isDestructiveAction,
      onPressed: () => onConfirm(hasSkip && !useSkipAction && skip),
    );
    return CupertinoAdaptiveDialog(
      title: title,
      content: !hasSkip || useSkipAction
          ? content
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ?content,
                _CupertinoConfirmSkipCheckbox(
                  value: skip,
                  onChanged: onSkipChanged!,
                ),
              ],
            ),
      actions: hasSkip && useSkipAction
          ? [
              confirmAction,
              AdaptiveDialogAction(
                label:
                    L10n.of(
                      context,
                    )?.confirmDialog_confirmAndSkip_text(confirmLabel) ??
                    "$confirmLabel, and don't ask again",
                isDestructiveAction: isDestructiveAction,
                onPressed: () => onConfirm(true),
              ),
              cancelAction,
            ]
          : [cancelAction, confirmAction],
    );
  }
}

class _CupertinoConfirmSkipCheckbox extends StatelessWidget {
  const _CupertinoConfirmSkipCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 28),
          child: Row(
            children: [
              CupertinoCheckbox(
                value: value,
                onChanged: (value) => onChanged(value ?? false),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  L10n.of(context)?.common_dontShowAgain ?? "Don't show again",
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
