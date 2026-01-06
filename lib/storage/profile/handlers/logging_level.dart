// Copyright 2024 Fries_I23
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

import '../../../logging/level.dart';
import '../profile_helper.dart';

class LoggingLevelProfileHandler
    extends ProfileHelperCovertToIntHandler<LogLevel?> {
  @override
  String get key => "loggingLevel";

  const LoggingLevelProfileHandler(
    super.pref, {
    super.codec = const LoggingLevelProfileCodec(),
  });
}

final class LoggingLevelProfileCodec extends Codec<LogLevel?, int> {
  const LoggingLevelProfileCodec();

  @override
  Converter<int, LogLevel?> get decoder => const _Decoder();

  @override
  Converter<LogLevel?, int> get encoder => const _Encoder();
}

final class _Decoder extends Converter<int, LogLevel?> {
  const _Decoder();

  @override
  LogLevel? convert(int input) => LogLevel.getFromDBCode(input);
}

final class _Encoder extends Converter<LogLevel, int> {
  const _Encoder();

  @override
  int convert(LogLevel input) => input.dbCode;
}
