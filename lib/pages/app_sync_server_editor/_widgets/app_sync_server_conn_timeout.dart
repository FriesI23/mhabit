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
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../common/consts.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/app_sync_server_form.dart';

class AppSyncServerConnTimeoutTile extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppSyncServerConnTimeoutTile({
    super.key,
    this.contentPadding,
    this.inputFormatters,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      contentPadding: contentPadding,
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: const Icon(MdiIcons.lanPending),
          labelText:
              l10n?.appSync_serverEditor_connTimeoutTile_titleText ??
              'Network Connection Timeout Seconds',
          hintText: l10n?.appSync_serverEditor_connTimeoutTile_hintText(
            defaultAppSyncConnectTimeout.inSeconds,
            l10n.appSync_serverEditor_connTimeoutTile_unitText,
          ),
          suffixText: l10n?.appSync_serverEditor_connTimeoutTile_unitText,
        ),
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ...?inputFormatters,
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class AppWebDavSyncServerConnTimeoutTile extends StatelessWidget {
  static const kAllowdMaxTimeoutSecond = 1800;

  final TextEditingController? controller;
  final ValueChanged<Duration?>? onChanged;

  const AppWebDavSyncServerConnTimeoutTile({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppSyncServerConnTimeoutTile(
      controller: controller,
      inputFormatters: [
        LengthLimitingTextInputFormatter(
          kAllowdMaxTimeoutSecond.toString().length,
        ),
      ],
      onChanged: (value) {
        final vm = context.read<AppSyncServerFormViewModel>();
        if (!vm.mounted || vm.webdav == null) return;
        if (value.isNotEmpty) {
          final realSecond = clampInt(
            num.parse(value).toInt(),
            min: 0,
            max: kAllowdMaxTimeoutSecond,
          );
          final realTimeout = Duration(seconds: realSecond).abs();
          vm.webdav?.connectTimeout = realTimeout;
        } else {
          vm.webdav?.connectTimeout = null;
        }
        onChanged?.call(vm.webdav?.connectTimeout);
      },
    );
  }
}
