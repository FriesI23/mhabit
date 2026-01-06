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
import '../../../widgets/widgets.dart';

class AppSyncServerFormInputField extends BaseTextEditingControllerWidget {
  final Widget Function(
    BuildContext context,
    AppSyncServerType type,
    TextEditingController controller,
    Widget? child,
  )
  builder;
  final String Function(AppSyncServerType type, AppSyncServerFormViewModel vm)
  valueBuilder;

  const AppSyncServerFormInputField({
    super.key,
    super.controller,
    required this.builder,
    required this.valueBuilder,
  });

  @override
  State<BaseTextEditingControllerWidget> createState() =>
      _AppSyncServerFormInputFieldState();
}

class _AppSyncServerFormInputFieldState
    extends BaseTextEditingControllerWidgetState<AppSyncServerFormInputField> {
  late AppSyncServerFormViewModel vm;
  late AppSyncServerType type;

  @override
  String get value => widget.valueBuilder(type, vm);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVm = context.read<AppSyncServerFormViewModel>();
    if (!controllerInitialized || !identical(vm, newVm)) {
      vm = newVm;
      type = vm.type;
    }
    ensureControllerInitialized();
  }

  @override
  void didUpdateWidget(AppSyncServerFormInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    ensureControllerUpdated(oldWidget);
    if (oldWidget.valueBuilder != widget.valueBuilder) {
      final newText = value;
      if (controller.text != newText) controller.text = newText;
    }
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
