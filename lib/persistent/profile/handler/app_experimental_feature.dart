// Copyright 2025 Fries_I23
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

import '../profile_helper.dart';

abstract mixin class AppExperimentalFeature<S, T>
    implements ProfileHelperConvertHandler<S, T> {
  @override
  String get key => "app_expf_$expKey";

  String get expKey;
}

abstract class AppExperimentalFeatureBool<T>
    extends ProfileHelperCovertToBoolHandler<T>
    with AppExperimentalFeature<T, bool> {
  const AppExperimentalFeatureBool(super.pref, {required super.codec});
}
