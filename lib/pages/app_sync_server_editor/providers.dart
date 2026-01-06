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

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import '../../models/app_sync_server.dart';
import '../../providers/app_sync.dart';
import '../../providers/app_sync_server_form.dart';
import '../../widgets/provider.dart';

class PageProviders extends SingleChildStatelessWidget {
  final AppSyncServer? initServerConfig;

  const PageProviders({super.key, super.child, this.initServerConfig});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) =>
            AppSyncServerFormViewModel(initServerConfig: initServerConfig),
      ),
      ViewModelProxyProvider<AppSyncViewModel, AppSyncServerFormViewModel>(
        update: (context, value, previous) => previous..attachParent(value),
      ),
    ],
    child: child,
  );
}
