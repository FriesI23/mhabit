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
import '../../../reminders/notification_channel.dart';
import '../../../reminders/notification_data.dart';
import '../../../reminders/notification_id_range.dart' as notifyid;
import '../../../reminders/notification_service.dart';
import '../../../utils/app_clock.dart';
import '../../common/widgets.dart';

class HabitDisplayDevelopSliverList extends StatefulWidget {
  final void Function(int count)? onAddCountHabitsPressed;

  const HabitDisplayDevelopSliverList({
    super.key,
    this.onAddCountHabitsPressed,
  });

  @override
  State<StatefulWidget> createState() => _HabitDisplayDevelopSliverList();
}

class _HabitDisplayDevelopSliverList
    extends State<HabitDisplayDevelopSliverList> {
  Widget _buildDebugHabitsButton(BuildContext context, int count) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.add),
      title: Text("Generate $count habits"),
      onTap: () => widget.onAddCountHabitsPressed?.call(count),
    );
  }

  Widget _buildNotificationTextButton(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.notification_add_outlined),
      title: const Text("Show demo notification"),
      onTap: () async {
        if (!mounted) return;
        final now = AppClock().now();
        NotificationService().show(
          id: notifyid.getRandomDebugId(),
          type: NotificationDataType.debug,
          title: "debug only",
          body: "timestamp: $now",
          channelId: NotificationChannelId.debug,
          details: context.read<NotificationChannelData>().habitReminder,
        );
      },
    );
  }

  Widget _buildCheckPendingNotificationTextButton(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.notification_important_outlined),
      title: const Text("Check pending notifications"),
      onTap: () => showNotificationPendingRequestsDialog(context: context),
    );
  }

  Widget _buildActiveNotificationTextButton(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: const Icon(Icons.notifications_active_outlined),
      title: const Text("Check active notifications"),
      onTap: () => showNotificationActivatedDialog(context: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Theme.of(context).colorScheme.outlineOpacity16),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            L10n.of(context)?.habitDisplay_debug_debugSubgroup_title ??
                'Developer',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          children: [
            _buildDebugHabitsButton(context, 1),
            _buildDebugHabitsButton(context, 20),
            _buildDebugHabitsButton(context, 100),
            _buildNotificationTextButton(context),
            _buildActiveNotificationTextButton(context),
            _buildCheckPendingNotificationTextButton(context),
          ],
        ),
      ),
    );
  }
}
