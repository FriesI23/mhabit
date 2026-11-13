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

import 'package:flutter/widgets.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/providers/app_ui/app_developer.dart';
import 'package:mhabit/providers/support/global.dart';

void main() {
  test('developer mode and debug menu remain independent', () {
    final viewModel = AppDeveloperViewModel(global: Global());
    addTearDown(viewModel.dispose);
    viewModel.switchDevelopMode(true);
    viewModel.switchDisplayDebugMenu(true);
    expect(viewModel.showDebugMenuOnDisplayView, isTrue);
    viewModel.switchDevelopMode(false);
    expect(viewModel.showDebugMenuOnDisplayView, isFalse);
    expect(viewModel.displayDebugMenu, isTrue);
  });

  test('text direction remains a runtime-only developer override', () {
    final first = AppDeveloperViewModel(global: Global());
    first.setTextDirectionOverride(TextDirection.rtl);
    expect(first.textDirectionOverride, TextDirection.rtl);
    first.dispose();
    final second = AppDeveloperViewModel(global: Global());
    addTearDown(second.dispose);
    expect(second.textDirectionOverride, isNull);
  });
}
