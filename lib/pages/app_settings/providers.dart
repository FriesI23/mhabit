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
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../providers/app_settings.dart';
import '../../storage/db_helper_provider.dart';
import '../../storage/profile_provider.dart';
import '../../widgets/provider.dart';

class PageProviders extends SingleChildStatelessWidget {
  const PageProviders({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
    providers: [
      ViewModelProxyProvider2<
        ProfileViewModel,
        DBHelperViewModel,
        AppSettingsViewModel
      >(
        create: (context) => AppSettingsViewModel(),
        update: (context, profile, dbHelper, previous) => previous
          ..updateProfile(profile)
          ..updateDBHelper(dbHelper),
      ),
      ListenableProxyProvider<AppSettingsViewModel, AppSettingsAccess>(
        create: (context) => context.read<AppSettingsViewModel>(),
        update: (context, value, previous) => value,
      ),
    ],
    child: child,
  );
}
