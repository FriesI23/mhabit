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

import 'dart:convert';

import '../../../models/app_apple_sidebar_style_mode.dart';
import '../profile_helper.dart';

final class AppleSidebarStyleModeProfileHandler
    extends ProfileHelperCovertToIntHandler<AppAppleSidebarStyleMode> {
  @override
  String get key => 'appleSidebarStyleMode';

  const AppleSidebarStyleModeProfileHandler(
    super.pref, {
    super.codec = const AppAppleSidebarStyleModeCodec(),
  });
}

final class AppAppleSidebarStyleModeCodec
    extends Codec<AppAppleSidebarStyleMode, int> {
  const AppAppleSidebarStyleModeCodec();

  @override
  Converter<int, AppAppleSidebarStyleMode> get decoder => const _Decoder();

  @override
  Converter<AppAppleSidebarStyleMode, int> get encoder => const _Encoder();
}

final class _Decoder extends Converter<int, AppAppleSidebarStyleMode> {
  const _Decoder();

  @override
  AppAppleSidebarStyleMode convert(int input) => switch (input) {
    1 => AppAppleSidebarStyleMode.os26,
    2 => AppAppleSidebarStyleMode.os27,
    _ => AppAppleSidebarStyleMode.automatic,
  };
}

final class _Encoder extends Converter<AppAppleSidebarStyleMode, int> {
  const _Encoder();

  @override
  int convert(AppAppleSidebarStyleMode input) => switch (input) {
    AppAppleSidebarStyleMode.automatic => 0,
    AppAppleSidebarStyleMode.os26 => 1,
    AppAppleSidebarStyleMode.os27 => 2,
  };
}
