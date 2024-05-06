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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../component/widget.dart';
import '../logging/level.dart';
import '../provider/app_debugger.dart';
import '../provider/app_developer.dart';
import 'common/_widget.dart';
import 'for_app_debugger/_widget.dart';

Future<void> naviToAppDebuggerPage({required BuildContext context}) async {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => const PageAppDebugger(),
    ),
  );
}

/// Depend Providers
/// - Required for builder:
///   - [AppDeveloperViewModel]
/// - Required for callback:
/// - Optional:
class PageAppDebugger extends StatelessWidget {
  const PageAppDebugger({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppDebuggerView();
  }
}

class AppDebuggerView extends StatefulWidget {
  const AppDebuggerView({super.key});

  @override
  State<StatefulWidget> createState() => AppDebuggerViewState();
}

class AppDebuggerViewState extends State<AppDebuggerView> {
  void _onLogLevelChanged(LogLevel newLevel) async {
    if (!mounted) return;
    context.read<AppDeveloperViewModel>().loggingLevel = newLevel;
  }

  void _onCollectLogsSwitcherChanged(bool newStatus) async {
    if (!mounted) return;
    context.read<AppDebuggerViewModel>().setCollectLogsSatus(newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Selector<AppDebuggerViewModel, bool>(
            selector: (context, vm) => vm.isCollectLogs,
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, isCollectLogs, child) {
              return ChangeLogsSwitcherTile(
                value: isCollectLogs,
                onChanged: _onCollectLogsSwitcherChanged,
              );
            },
          ),
          Selector<AppDeveloperViewModel, LogLevel>(
            selector: (context, vm) => vm.loggingLevel,
            shouldRebuild: (previous, next) => previous != next,
            builder: (context, logLevel, child) {
              return LogLevelChangerTile(
                crtLevel: logLevel,
                onSelected: _onLogLevelChanged,
              );
            },
          ),
        ],
      ),
    );
  }
}
