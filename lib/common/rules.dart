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

/// Length constraint with a soft validation limit and a wider IME-friendly
/// hard cap.
abstract interface class StringLengthRule {
  int get softLimit;
  int get hardLimit;

  /// Truncate to [softLimit] when exceeded.
  String clamp(String value);
}

class SimpleStringLengthRule implements StringLengthRule {
  @override
  final int softLimit;

  @override
  final int hardLimit;

  const SimpleStringLengthRule(this.softLimit, {int? hardLimit})
    : hardLimit = hardLimit ?? softLimit;

  @override
  String clamp(String value) =>
      value.length > softLimit ? value.substring(0, softLimit) : value;
}

const groupNameRule = SimpleStringLengthRule(100);
const groupDescRule = SimpleStringLengthRule(300, hardLimit: 600);
