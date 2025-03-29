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

import '../../common/consts.dart';
import '../../common/utils.dart';
import '../../l10n/localizations.dart';
import '../../model/app_sync_server.dart';
import '../../provider/app_sync_server_form.dart';

class AppSyncServerTimeoutTile extends StatefulWidget {
  static const kAllowdMaxTimeoutSecond = 3600;

  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerTimeoutTile({super.key, this.contentPadding});

  @override
  State<AppSyncServerTimeoutTile> createState() => _AppSyncServerTimeoutTile();
}

class _AppSyncServerTimeoutTile extends State<AppSyncServerTimeoutTile> {
  late TextEditingController controller;
  late AppSyncServerFormViewModel vm;
  late AppSyncServerType crtType;

  String get crtText => vm.timeout?.inSeconds.toString() ?? '';

  @override
  void initState() {
    vm = context.read<AppSyncServerFormViewModel>();
    crtType = vm.type;
    controller =
        TextEditingController.fromValue(TextEditingValue(text: crtText));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (crtType != vm.type) {
      crtType = vm.type;
      controller.text = crtText;
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _onChange(String value) {
    if (value.isNotEmpty) {
      final realSecond = clampInt(int.parse(value),
          min: 0, max: AppSyncServerTimeoutTile.kAllowdMaxTimeoutSecond);
      final realTimeout = Duration(seconds: realSecond).abs();
      vm.timeout = realTimeout;
      controller.text = realTimeout.inSeconds.toString();
    } else {
      vm.timeout = null;
      controller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    context
        .select<AppSyncServerFormViewModel, AppSyncServerType>((vm) => vm.type);
    debugPrint(controller.text);
    final l10n = L10n.of(context);
    return ListTile(
      contentPadding: widget.contentPadding,
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          icon: const Icon(MdiIcons.timerOutline),
          labelText: l10n?.appSync_serverEditor_timeoutTile_titleText ??
              'Sync Timeout Seconds',
          hintText: l10n?.appSync_serverEditor_timeoutTile_hintText(
              defaultAppSyncTimeout.inSeconds,
              l10n.appSync_serverEditor_timeoutTile_unitText),
          suffixText: l10n?.appSync_serverEditor_timeoutTile_unitText,
        ),
        keyboardType: const TextInputType.numberWithOptions(
            signed: false, decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(AppSyncServerTimeoutTile
              .kAllowdMaxTimeoutSecond
              .toString()
              .length)
        ],
        onChanged: _onChange,
      ),
    );
  }
}
