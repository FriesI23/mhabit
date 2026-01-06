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

import '../../common/utils.dart';

enum PageBackReason { back, close }

class PageBackButton extends StatelessWidget {
  final PageBackReason reason;
  final Color? color;
  final VoidCallback? onPressed;

  const PageBackButton({
    super.key,
    this.reason = PageBackReason.back,
    this.color,
    this.onPressed,
  });

  void _onPressedCallback(BuildContext context) => dismissAllToolTips().then(
    (_) => context.mounted ? Navigator.maybePop(context) : false,
  );

  @override
  Widget build(BuildContext context) {
    switch (reason) {
      case PageBackReason.back:
        return Center(
          child: BackButton(
            onPressed: onPressed ?? () => _onPressedCallback(context),
            color: color,
          ),
        );
      case PageBackReason.close:
        return Center(
          child: CloseButton(
            onPressed: onPressed ?? () => _onPressedCallback(context),
            color: color,
          ),
        );
    }
  }
}
