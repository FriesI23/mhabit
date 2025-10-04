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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.dart';
import '../../../models/app_sync_server.dart';
import '../../../providers/app_sync_server_form.dart';

class AppSyncServerNetworkTypeTile extends StatelessWidget {
  const AppSyncServerNetworkTypeTile({super.key});

  Widget? _buildNetworkTypeChip(
      BuildContext context, AppSyncServerMobileNetwork type) {
    void onSelected(bool newValue) {
      final vm = context.read<AppSyncServerFormViewModel>();
      final syncMobileNetworks = (vm.syncMobileNetworks?.toSet() ?? const {});
      final result = newValue
          ? syncMobileNetworks.add(type)
          : syncMobileNetworks.remove(type);
      if (result) vm.syncMobileNetworks = syncMobileNetworks;
    }

    final l10n = L10n.of(context);
    final title = l10n?.appSync_networkType_text(type.name);
    final tooltips =
        l10n?.appSync_serverEditor_netTypeTile_typeTooltip(type.name);

    final syncMobileNetworks = context
        .select<AppSyncServerFormViewModel, List<AppSyncServerMobileNetwork>>(
            (vm) => vm.syncMobileNetworks?.toList() ?? const []);
    final theme = Theme.of(context);
    return switch (type) {
      AppSyncServerMobileNetwork.mobile => FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(MdiIcons.signal, size: 20.0),
              Text(title ?? 'Mobile'),
            ],
          ),
          selectedColor: theme.brightness == Brightness.dark
              ? Colors.green
              : Colors.lightGreen,
          selected: syncMobileNetworks.contains(type),
          onSelected: onSelected,
          tooltip: tooltips,
        ),
      AppSyncServerMobileNetwork.wifi => FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(MdiIcons.signalVariant, size: 20.0),
              Text(title ?? "Wifi"),
            ],
          ),
          selectedColor: theme.brightness == Brightness.dark
              ? Colors.blue
              : Colors.lightBlue,
          selected: syncMobileNetworks.contains(type),
          onSelected: onSelected,
          tooltip: tooltips,
        ),
      _ => null,
    };
  }

  Widget _buildLowDataModeChip(BuildContext context) {
    final syncInLowData = context
        .select<AppSyncServerFormViewModel, bool?>((vm) => vm.syncInLowData);
    final theme = Theme.of(context);
    final l10n = L10n.of(context);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(MdiIcons.swapHorizontal, size: 20.0),
          Text(l10n?.appSync_serverEditor_netTypeTile_lowDataText ?? "LowData"),
        ],
      ),
      selectedColor:
          theme.brightness == Brightness.dark ? Colors.grey : Colors.grey,
      selected: syncInLowData == true,
      onSelected: (newValue) {
        context.read<AppSyncServerFormViewModel>().syncInLowData = newValue;
      },
      tooltip: l10n?.appSync_serverEditor_netTypeTile_lowDataTooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildNetworksSubtitle(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 12.0,
          children: [
            ...AppSyncServerMobileNetwork.allowed
                .map((type) => _buildNetworkTypeChip(context, type))
                .nonNulls,
            _buildLowDataModeChip(context),
          ],
        ),
      );
    }

    final type = context
        .select<AppSyncServerFormViewModel, AppSyncServerType>((vm) => vm.type);
    final l10n = L10n.of(context);
    return Visibility(
      visible: type.includeSyncNetworkField,
      child: ListTile(
        isThreeLine: true,
        leading: const Icon(MdiIcons.accessPointNetwork),
        title: Text(l10n?.appSync_serverEditor_netTypeTile_titleText ??
            "Synchronous Networking"),
        subtitle: buildNetworksSubtitle(context),
      ),
    );
  }
}
