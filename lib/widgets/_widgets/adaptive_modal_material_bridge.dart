// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

/// Temporarily hosts Material-only content inside an adaptive modal.
///
/// The inherited text style is forwarded so a Cupertino modal keeps its
/// typography while legacy Material widgets receive the ancestor required for
/// ink and lookup behavior.
// FIXME(mhabit): Remove this bridge after all migrated modal consumers use
// adaptive controls with Cupertino renderers.
class AdaptiveModalMaterialBridge extends StatelessWidget {
  const AdaptiveModalMaterialBridge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    textStyle: DefaultTextStyle.of(context).style,
    child: child,
  );
}
