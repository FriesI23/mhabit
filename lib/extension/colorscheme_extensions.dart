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

extension CustomColorScheme on ColorScheme {
  Color get outlineOpacity64 => outline.withOpacity(0.64);

  Color get outlineOpacity48 => outline.withOpacity(0.48);

  Color get outlineOpacity32 => outline.withOpacity(0.32);

  Color get outlineOpacity16 => outline.withOpacity(0.16);

  Color get onSurfaceOpacity08 => onSurface.withOpacity(0.08);

  Color get primaryContainerOpacity32 => primaryContainer.withOpacity(0.32);
}
