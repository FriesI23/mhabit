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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/localizations.g.dart';
import '../../../models/app_sync_server.dart';
import '../../../providers/app_sync_server_form.dart';

class AppSyncServerTypeMenu extends StatelessWidget {
  final double? width;
  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerTypeMenu({
    super.key,
    this.width,
    this.contentPadding,
  });

  String getName(AppSyncServerType type, {bool isCurrent = false, L10n? l10n}) {
    if (l10n != null) {
      return l10n.appSync_syncServerType_text(type.name, isCurrent.toString());
    }
    switch (type) {
      case AppSyncServerType.webdav:
        return 'WebDAV';
      case AppSyncServerType.fake:
        return "Fake (Only For Debugger)";
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildMenu(BuildContext context, double? width) {
      final l10n = L10n.of(context);
      final vm = context.watch<AppSyncServerFormViewModel>();
      return DropdownMenu<AppSyncServerType>(
        width: width,
        enableSearch: false,
        requestFocusOnTap: false,
        initialSelection: vm.type,
        dropdownMenuEntries: AppSyncServerType.values
            .where((e) => e != AppSyncServerType.unknown)
            .where((e) =>
                e != AppSyncServerType.fake ||
                (kDebugMode || vm.type == AppSyncServerType.fake))
            .map((e) => DropdownMenuEntry(
                value: e,
                label: getName(e, l10n: l10n, isCurrent: e == vm.type)))
            .toList(),
        onSelected: (value) =>
            context.read<AppSyncServerFormViewModel>().type = value!,
      );
    }

    if (width != null) {
      return ListTile(
        contentPadding: contentPadding,
        title: buildMenu(context, width! > 0 ? width : null),
      );
    } else {
      return ListTile(
        contentPadding: contentPadding,
        title: LayoutBuilder(
          builder: (context, constraints) =>
              buildMenu(context, constraints.maxWidth),
        ),
      );
    }
  }
}
