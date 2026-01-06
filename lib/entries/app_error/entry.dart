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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../common/consts.dart';
import '../../pages/app_error/page.dart' as app_error;
import '../../theme/color.dart';
import '../common/app_root_view.dart';

class AppErrorEntry extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const AppErrorEntry({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return AppRootView.withDefault(
      lightThemeBuilder: () => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appDefaultThemeMainColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        extensions: [modifedLightCustomColors],
      ),
      darkThemeBuilder: () => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appDefaultThemeMainColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        extensions: [darkCustomColors],
      ),
      child: app_error.AppErrorPage(
        details: errorDetails,
        showCloseBtn: switch (defaultTargetPlatform) {
          TargetPlatform.android => true,
          _ => false,
        },
      ),
    );
  }
}
