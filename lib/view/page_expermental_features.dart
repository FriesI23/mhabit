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
import 'package:provider/provider.dart';

import '../component/widget.dart';
import '../extension/context_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../provider/app_sync.dart';

import 'page_app_sync.dart' as app_sync;

Future<void> naviToExpFeaturesPage({required BuildContext context}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => const PageExpermentalFeatures(),
    ),
  );
}

class PageExpermentalFeatures extends StatelessWidget {
  const PageExpermentalFeatures({super.key});

  @override
  Widget build(BuildContext context) => const ExpermentalFeaturesView();
}

class ExpermentalFeaturesView extends StatefulWidget {
  const ExpermentalFeaturesView({super.key});

  @override
  State<StatefulWidget> createState() => _ExpermentalFeaturesView();
}

final class _ExpermentalFeaturesView extends State<ExpermentalFeaturesView> {
  AppSyncViewModel? syncvm;
  bool showWarningBanner = false;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    syncvm = context.maybeRead<AppSyncViewModel>();
    if ([syncvm?.expFeatureEnabled].any((e) => e == true)) {
      showWarningBanner = true;
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    final oldSyncvm = syncvm;
    syncvm = context.maybeRead<AppSyncViewModel>();
    final oldShown = showWarningBanner;
    showWarningBanner = [syncvm?.expFeatureEnabled].any((e) => e == true);
    if (oldSyncvm != syncvm || oldShown != showWarningBanner) setState(() {});
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    appLog.build.debug(context, ex: ["dispose"], widget: widget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
          leading: const PageBackButton(reason: PageBackReason.back),
          title: Text("Expermental Features")),
      body: ListView(
        children: [
          ExpandedSection(
            expand: showWarningBanner,
            child: MaterialBanner(
                forceActionsBelow: true,
                leading: const Icon(Icons.warning_amber_outlined),
                content: Text("One or more experimental features are enabled. "
                    "Use with caution."),
                actions: [
                  TextButton(
                      onPressed: () =>
                          setState(() => showWarningBanner = false),
                      child: Text(l10n?.snackbar_dismissText ?? "DISMISS")),
                ]),
          ),
          if (syncvm != null) ...[
            Selector<AppSyncViewModel, bool>(
              selector: (context, vm) => vm.expFeatureEnabled,
              builder: (context, value, child) => SwitchListTile(
                  title: Text("Habit Network Sync"),
                  subtitle: Text("Once enabled, "
                      "the app sync entry will be shown in settings."),
                  value: value,
                  onChanged: (value) {
                    syncvm?.setExpFeatureSwitch(value);
                    if (syncvm?.expFeatureEnabled == true) {
                      setState(() => showWarningBanner = true);
                    }
                  }),
            ),
            Selector<AppSyncViewModel, bool>(
              selector: (context, vm) => vm.enabled && !vm.expFeatureEnabled,
              builder: (context, value, child) => ExpandedSection(
                  expand: value,
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_outlined),
                    title: const Text(
                      "Experimental feature (Habit Network Sync) is disabled, "
                      "but the function is still running.",
                    ),
                    subtitle: const Text(
                      "To completely disable, "
                      "long press to access 'Sync Option' and turn it off.",
                    ),
                    onLongPress: () =>
                        app_sync.naviToAppSyncPage(context: context),
                  )),
            )
          ],
        ],
      ),
    );
  }
}
