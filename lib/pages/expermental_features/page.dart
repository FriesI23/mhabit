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

import '../../extensions/context_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../providers/app_experimental_feature.dart';
import '../../widgets/widgets.dart';

Future<void> naviToExperimentalFeaturesPage({required BuildContext context}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => const ExpermentalFeaturesPage(),
    ),
  );
}

class ExpermentalFeaturesPage extends StatelessWidget {
  const ExpermentalFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) => const _Page();
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<StatefulWidget> createState() => _PageState();
}

final class _PageState extends State<_Page> {
  AppExperimentalFeatureViewModel? vm;
  bool showWarningBanner = false;

  bool shouldShowWarningBanner() =>
      vm?.allFeatures.any((e) => e.enabled) == true;

  @override
  void initState() {
    appLog.build.debug(context, ex: ["init"]);
    vm = context.maybeRead<AppExperimentalFeatureViewModel>();
    if (shouldShowWarningBanner()) showWarningBanner = true;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final oldSyncvm = vm;
    vm = context.maybeRead<AppExperimentalFeatureViewModel>();
    final oldShown = showWarningBanner;
    showWarningBanner = shouldShowWarningBanner();
    if (oldSyncvm != vm || oldShown != showWarningBanner) setState(() {});
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

    List<Widget> buildHabitSearchWidgets(BuildContext context) => [
          Selector<AppExperimentalFeatureViewModel, bool>(
            selector: (context, vm) => vm.habitSearch,
            builder: (context, value, child) => SwitchListTile(
                title: Text(
                    l10n?.experimentalFeatures_habitSearchTile_titleText ??
                        "Habit Search"),
                subtitle: l10n != null
                    ? Text(
                        l10n.experimentalFeatures_habitSearchTile_subtitleText)
                    : null,
                value: value,
                onChanged: (value) async {
                  await vm?.setHabitSearch(value);
                  if (vm?.habitSearch == true) {
                    setState(() => showWarningBanner = true);
                  }
                }),
          ),
        ];

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
          if (vm != null) ...buildHabitSearchWidgets(context)
        ],
      ),
    );
  }
}
