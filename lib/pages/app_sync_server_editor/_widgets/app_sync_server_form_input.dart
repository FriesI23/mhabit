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

import '../../../models/app_sync_server.dart';
import '../../../providers/app_sync_server_form.dart';

class AppSyncServerFormInputField extends StatefulWidget {
  final TextEditingController? controller;
  final Widget Function(BuildContext context, AppSyncServerType value,
      TextEditingController controller, Widget? child) builder;
  final String Function(AppSyncServerType t, AppSyncServerFormViewModel vm)
      getValue;

  const AppSyncServerFormInputField({
    super.key,
    this.controller,
    required this.builder,
    required this.getValue,
  });

  @override
  State<StatefulWidget> createState() => _AppSyncServerFormInputFieldState();
}

class _AppSyncServerFormInputFieldState
    extends State<AppSyncServerFormInputField> {
  late TextEditingController controller;
  late AppSyncServerFormViewModel vm;
  late AppSyncServerType type;

  _AppSyncServerFormInputFieldState();

  String get value => widget.getValue(type, vm);

  @override
  void initState() {
    vm = context.read<AppSyncServerFormViewModel>();
    type = vm.type;
    controller = widget.controller != null
        ? (widget.controller!..text = value)
        : TextEditingController.fromValue(TextEditingValue(text: value));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (type != vm.type) {
      type = vm.type;
      controller.text = value;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.controller == null) controller.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Selector<AppSyncServerFormViewModel, AppSyncServerType>(
        selector: (context, vm) => vm.type,
        builder: (context, value, child) =>
            widget.builder(context, value, controller, child),
      );
}
