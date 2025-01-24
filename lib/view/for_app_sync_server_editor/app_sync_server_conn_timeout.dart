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
import 'package:provider/provider.dart';

import '../../common/consts.dart';
import '../../common/utils.dart';
import '../../provider/app_sync_server_form.dart';

class AppSyncServerConnTimeoutTile extends StatefulWidget {
  static const kAllowdMaxTimeoutSecond = 600;

  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerConnTimeoutTile({super.key, this.contentPadding});

  @override
  State<AppSyncServerConnTimeoutTile> createState() =>
      _AppSyncServerConnTimeoutTile();
}

class _AppSyncServerConnTimeoutTile
    extends State<AppSyncServerConnTimeoutTile> {
  late TextEditingController controller;
  late AppSyncServerFormViewModel vm;

  @override
  void initState() {
    vm = context.read<AppSyncServerFormViewModel>();
    controller = TextEditingController.fromValue(
        TextEditingValue(text: vm.connectTimeout?.inSeconds.toString() ?? ''));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _onChange(String value) {
    if (value.isNotEmpty) {
      final realSecond = clampInt(num.parse(value).toInt(),
          min: 0, max: AppSyncServerConnTimeoutTile.kAllowdMaxTimeoutSecond);
      final realTimeout = Duration(seconds: realSecond).abs();
      vm.connectTimeout = realTimeout;
      controller.text = realTimeout.inSeconds.toString();
    } else {
      vm.connectTimeout = null;
      controller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: widget.contentPadding,
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Network Connection Timeout Seconds',
          hintText: 'Default: ${defaultAppSyncConnectTimeout.inSeconds}s',
        ),
        keyboardType: const TextInputType.numberWithOptions(
            signed: false, decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(AppSyncServerConnTimeoutTile
              .kAllowdMaxTimeoutSecond
              .toString()
              .length)
        ],
        onChanged: _onChange,
      ),
    );
  }
}

class AppSyncServerConnRetryCountTile extends StatefulWidget {
  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerConnRetryCountTile({super.key, this.contentPadding});

  @override
  State<AppSyncServerConnRetryCountTile> createState() =>
      _AppSyncServerConnRetryCountTile();
}

class _AppSyncServerConnRetryCountTile
    extends State<AppSyncServerConnRetryCountTile> {
  late TextEditingController controller;
  late AppSyncServerFormViewModel vm;

  @override
  void initState() {
    vm = context.read<AppSyncServerFormViewModel>();
    controller = TextEditingController.fromValue(
        TextEditingValue(text: vm.connectRetryCount?.toString() ?? ''));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _onChange(String value) {
    if (value.isNotEmpty) {
      final count = clampInt(num.parse(value).toInt(), min: 0);
      vm.connectRetryCount = count;
      controller.text = count.toString();
    } else {
      vm.connectRetryCount = null;
      controller.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: widget.contentPadding,
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Network Connection Retry Count',
          hintText: 'Default: Unlimited',
        ),
        keyboardType: const TextInputType.numberWithOptions(
            signed: false, decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: _onChange,
      ),
    );
  }
}
