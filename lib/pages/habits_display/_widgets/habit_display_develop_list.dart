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
import 'package:provider/provider.dart';

import '../../../extensions/colorscheme_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/app_ui/app_debugger.dart';
import '../../../storage/profile/handlers.dart';
import '../../../storage/profile_provider.dart';
import '../../common/widgets.dart';
import 'changelog_banner_sliver.dart';

class HabitDisplayDevelopSliverList extends StatefulWidget {
  final void Function(int count, bool withGroups)? onAddCountHabitsPressed;

  const HabitDisplayDevelopSliverList({
    super.key,
    this.onAddCountHabitsPressed,
  });

  @override
  State<StatefulWidget> createState() => _HabitDisplayDevelopSliverList();
}

class _HabitDisplayDevelopSliverList
    extends State<HabitDisplayDevelopSliverList> {
  bool _withGroups = true;

  Widget _buildDebugHabitsButton(int count) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.add),
      title: Text("Generate $count habits"),
      onTap: () => widget.onAddCountHabitsPressed?.call(count, _withGroups),
    );
  }

  Widget _buildNotificationTextButton() {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.notification_add_outlined),
      title: const Text("Show demo notification"),
      onTap: () async {
        if (!mounted) return;
        await context.read<AppDebuggerViewModel>().showDemoNotification();
      },
    );
  }

  Widget _buildCheckPendingNotificationTextButton() {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.notification_important_outlined),
      title: const Text("Check pending notifications"),
      onTap: () => showNotificationPendingRequestsDialog(context: context),
    );
  }

  Widget _buildActiveNotificationTextButton() {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.notifications_active_outlined),
      title: const Text("Check active notifications"),
      onTap: () => showNotificationActivatedDialog(context: context),
    );
  }

  Widget _buildChangelogBannerButton() {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.celebration_outlined),
      title: const Text('Show Changelog Banner'),
      onTap: () => showChangelogBanner(context, useLatestFallback: true),
    );
  }

  Widget _buildClearChangelogVersionButton() {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.cleaning_services_outlined),
      title: const Text('Clear last changelog version'),
      subtitle: const Text('Restart to re-trigger the banner'),
      onTap: () async {
        await context
            .read<ProfileViewModel>()
            .getHandler<AppLastChangelogVersionProfileHandler>()
            ?.remove();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Changelog version cleared')),
          );
        }
      },
    );
  }

  Widget _buildGroupCheckbox() {
    return CheckboxListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      value: _withGroups,
      title: const Text('Use groups (Many, Medium, Few)'),
      onChanged: (value) => setState(() => _withGroups = value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Theme.of(context).colorScheme.outlineOpacity16,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            L10n.of(context)?.habitDisplay_debug_debugSubgroup_title ??
                'Developer',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          children: [
            _buildGroupCheckbox(),
            _buildDebugHabitsButton(1),
            _buildDebugHabitsButton(20),
            _buildDebugHabitsButton(100),
            _buildNotificationTextButton(),
            _buildActiveNotificationTextButton(),
            _buildCheckPendingNotificationTextButton(),
            _buildChangelogBannerButton(),
            _buildClearChangelogVersionButton(),
          ],
        ),
      ),
    );
  }
}
