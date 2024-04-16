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
      title: titleBuilder != null ? titleBuilder(context) : title,
      subtitle: subtitleBuilder != null ? subtitleBuilder(context) : subtitle,
      cancelText:
          cancelTextBuilder != null ? cancelTextBuilder(context) : cancelText,
      confirmText: confirmTextBuilder != null
          ? confirmTextBuilder(context)
          : confirmText,
    ),
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
          )
      ],
    );
  }
}
