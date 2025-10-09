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
  final Widget Function(
    BuildContext context,
    AppSyncServerType type,
    TextEditingController controller,
    Widget? child,
  ) builder;
  final String Function(AppSyncServerType type, AppSyncServerFormViewModel vm)
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
  late AppSyncServerFormViewModel vm;
  late AppSyncServerType type;
  late TextEditingController controller;
  bool _controllerInitialized = false;

  String get value => widget.getValue(type, vm);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVm = context.read<AppSyncServerFormViewModel>();
    if (!_controllerInitialized || !identical(vm, newVm)) {
      vm = newVm;
      type = vm.type;
      if (!_controllerInitialized) _initController();
    }
  }

  void _initController() {
    if (widget.controller != null) {
      controller = widget.controller!;
      if (controller.text != value) controller.text = value;
    } else {
      controller = TextEditingController(text: value);
    }
    _controllerInitialized = true;
  }

  @override
  void didUpdateWidget(covariant AppSyncServerFormInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      final oldController = controller;
      if (widget.controller != null) {
        controller = widget.controller!;
        if (controller.text != value) controller.text = value;
      } else {
        controller = TextEditingController(text: value);
      }
      if (oldWidget.controller == null) oldController.dispose();
    } else if (oldWidget.getValue != widget.getValue) {
      final newText = value;
      if (controller.text != newText) controller.text = newText;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppSyncServerFormViewModel, AppSyncServerType>(
      selector: (context, vm) => vm.type,
      builder: (context, newType, child) {
        if (newType != type) {
          type = newType;
          final newValue = value;
          if (controller.text != newValue) controller.text = newValue;
        }
        return widget.builder(context, newType, controller, child);
      },
    );
  }
}
