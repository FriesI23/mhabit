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
import 'package:flutter/services.dart';

import '../../common/rules.dart';

/// UI helpers for [StringLengthRule].
extension StringLengthRuleUI on StringLengthRule {
  /// Counter for the soft/hard split pattern:
  /// `maxLength: softLimit` + [MaxLengthEnforcement.none] +
  /// [hardLimitFormatter].
  ///
  /// Displays "X / softLimit" and turns red when the current length exceeds
  /// [softLimit].
  InputCounterWidgetBuilder get buildSoftLimitCounter =>
      (context, {required currentLength, maxLength, required isFocused}) {
        final len = currentLength;
        return Text(
          '$len / $softLimit',
          style: TextStyle(
            color: len > softLimit ? Theme.of(context).colorScheme.error : null,
          ),
        );
      };

  /// [LengthLimitingTextInputFormatter] at [hardLimit].
  TextInputFormatter get hardLimitFormatter =>
      LengthLimitingTextInputFormatter(hardLimit);
}
