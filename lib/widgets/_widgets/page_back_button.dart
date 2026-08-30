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
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

enum PageBackReason { back, close }

@Deprecated(
  'Use AdaptiveBackButton with AdaptiveBackButtonType instead. '
  'PageBackButton is a temporary compatibility wrapper and will be removed.',
)
class PageBackButton extends StatelessWidget {
  final PageBackReason reason;
  final Color? color;
  final VoidCallback? onPressed;
  final AdaptiveStyle? style;

  const PageBackButton({
    super.key,
    this.reason = PageBackReason.back,
    this.color,
    this.onPressed,
  }) : style = null;

  const PageBackButton.material({
    super.key,
    this.reason = PageBackReason.back,
    this.color,
    this.onPressed,
  }) : style = AdaptiveStyle.material;

  const PageBackButton.apple({
    super.key,
    this.reason = PageBackReason.back,
    this.color,
    this.onPressed,
  }) : style = AdaptiveStyle.apple;

  @override
  Widget build(BuildContext context) => switch (style) {
    AdaptiveStyle.material => AdaptiveBackButton.material(
      type: _adaptiveType,
      color: color,
      onPressed: onPressed,
    ),
    AdaptiveStyle.apple => AdaptiveBackButton.apple(
      type: _adaptiveType,
      color: color,
      onPressed: onPressed,
    ),
    null => AdaptiveBackButton(
      type: _adaptiveType,
      color: color,
      onPressed: onPressed,
    ),
  };

  AdaptiveBackButtonType get _adaptiveType => switch (reason) {
    PageBackReason.back => AdaptiveBackButtonType.back,
    PageBackReason.close => AdaptiveBackButtonType.close,
  };
}
