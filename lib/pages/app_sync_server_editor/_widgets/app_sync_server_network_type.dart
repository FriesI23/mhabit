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
  final Widget? child;

  const AppSyncServerNetworkTypeTile({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      isThreeLine: true,
      leading: const Icon(MdiIcons.accessPointNetwork),
      title: Text(
        l10n?.appSync_serverEditor_netTypeTile_titleText ??
            "Synchronous Networking",
      ),
      subtitle: Padding(padding: const EdgeInsets.only(top: 6.0), child: child),
    );
  }
}

class _NetworkTypeChip extends StatelessWidget {
  final AppSyncServerMobileNetwork type;
  final Iterable<AppSyncServerMobileNetwork> syncMobileNetworks;
  final ValueChanged<bool>? onSelected;

  const _NetworkTypeChip({
    required this.type,
    this.syncMobileNetworks = const [],
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    assert(AppSyncServerMobileNetwork.allowed.contains(type));

    final l10n = L10n.of(context);
    final title = l10n?.appSync_networkType_text(type.name);
    final tooltips = l10n?.appSync_serverEditor_netTypeTile_typeTooltip(
      type.name,
    );
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
      _ => throw UnimplementedError(),
    };
  }
}

class _LowDataModeChip extends StatelessWidget {
  final bool syncInLowData;
  final ValueChanged<bool>? onSelected;

  const _LowDataModeChip({required this.syncInLowData, this.onSelected});

  @override
  Widget build(BuildContext context) {
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
      selectedColor: theme.brightness == Brightness.dark
          ? Colors.grey
          : Colors.grey,
      selected: syncInLowData,
      onSelected: onSelected,
      tooltip: l10n?.appSync_serverEditor_netTypeTile_lowDataTooltip,
    );
  }
}

class AppWebDavSyncServerNetworkTypeTile extends StatelessWidget {
  const AppWebDavSyncServerNetworkTypeTile({super.key});

  Widget _buildNetworkTypeChip(
    BuildContext context,
    AppSyncServerMobileNetwork type,
    Set<AppSyncServerMobileNetwork> syncMobileNetworks,
  ) {
    return _NetworkTypeChip(
      type: type,
      syncMobileNetworks: syncMobileNetworks,
      onSelected: (value) {
        final vm = context.read<AppSyncServerFormViewModel>();
        if (!vm.mounted || vm.webdav == null) return;
        final syncMobileNetworks = vm.webdav?.syncMobileNetworks?.toSet() ?? {};
        final result = value
            ? syncMobileNetworks.add(type)
            : syncMobileNetworks.remove(type);
        if (result) vm.webdav?.syncMobileNetworks = syncMobileNetworks;
      },
    );
  }

  Widget _buildLowDataModeChip(BuildContext context, bool? syncInLowData) {
    return _LowDataModeChip(
      syncInLowData: syncInLowData ?? false,
      onSelected: (value) {
        final vm = context.read<AppSyncServerFormViewModel>();
        if (!vm.mounted || vm.webdav == null) return;
        vm.webdav?.syncInLowData = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.select<AppSyncServerFormViewModel, bool>((vm) => vm.webdav != null);
    return AppSyncServerNetworkTypeTile(
      child:
          Selector<
            AppSyncServerFormViewModel,
            ({Iterable<AppSyncServerMobileNetwork>? networks, bool? lowData})
          >(
            selector: (context, vm) => (
              networks: vm.webdav?.syncMobileNetworks,
              lowData: vm.webdav?.syncInLowData,
            ),
            builder: (context, value, child) {
              final networks = value.networks?.toSet() ?? {};
              return Wrap(
                spacing: 8.0,
                runSpacing: 12.0,
                children: [
                  ...AppSyncServerMobileNetwork.allowed.map(
                    (type) => _buildNetworkTypeChip(context, type, networks),
                  ),
                  _buildLowDataModeChip(context, value.lowData),
                ],
              );
            },
          ),
    );
  }
}
