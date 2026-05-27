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

import 'package:flutter/material.dart';

import '../../../widgets/widgets.dart';
import 'not_found_image.dart';

class LoadErrorPlaceholder extends StatelessWidget {
  final VoidCallback? onRetry;
  final Widget? message;
  final Size size;
  final EdgeInsetsGeometry padding;

  const LoadErrorPlaceholder({
    super.key,
    this.onRetry,
    this.message,
    this.size = const Size.square(300),
    this.padding = const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
  });

  @override
  Widget build(BuildContext context) {
    return L10nBuilder(
      builder: (context, l10n) => NotFoundImage(
        size: size,
        padding: padding,
        descChild: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            message ??
                (l10n != null
                    ? Text(l10n.common_loadError_text)
                    : const Text('Failed to load')),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: l10n != null
                    ? Text(l10n.common_loadError_retryText)
                    : const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }
}
