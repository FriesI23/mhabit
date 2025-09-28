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

import '../extension/context_extensions.dart';
import '../l10n/localizations.dart';
import '../logging/helper.dart';
import '../providers/app_sync.dart';
import '../widgets/widget.dart';
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
          title: Text(l10n?.appSetting_experimentalFeatureTile_titleText ??
              "Experimental Features")),
      body: ListView(
        children: [
          ExpandedSection(
            expand: showWarningBanner,
            child: MaterialBanner(
                forceActionsBelow: true,
                leading: const Icon(Icons.warning_amber_outlined),
                content: Text(l10n?.experimentalFeatures_warnginBanner_title ??
                    "Experimental features are enabled."),
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
                  title: Text(
                      l10n?.experimentalFeatures_habitSyncTile_titleText ??
                          "Habit Sync"),
                  subtitle: l10n != null
                      ? Text(
                          l10n.experimentalFeatures_habitSyncTile_subtitleText)
                      : null,
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
                    title: Text(l10n?.experimentalFeatures_warnTile_titleText(
                            l10n.experimentalFeatures_habitSyncTile_titleText) ??
                        "Experimental feature (Habit Network Sync) is off, "
                            "but function still running."),
                    subtitle: l10n != null
                        ? Text(
                            l10n.experimentalFeatures_warnTile_forHabitSyncText(
                                l10n.appSetting_syncOption_titleText))
                        : null,
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
