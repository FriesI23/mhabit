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

import '../../../providers/habit_form.dart';
import '../../../widgets/widgets.dart';

class HabitEditFormInputField extends BaseTextEditingControllerWidget {
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    Widget? child,
  ) builder;
  final String Function(HabitFormViewModel vm) valueBuilder;
  final Widget? child;

  const HabitEditFormInputField({
    super.key,
    super.controller,
    required this.builder,
    required this.valueBuilder,
    this.child,
  });

  @override
  State<BaseTextEditingControllerWidget> createState() =>
      _HabitEditFormInputFieldState();
}

class _HabitEditFormInputFieldState
    extends BaseTextEditingControllerWidgetState<HabitEditFormInputField> {
  late HabitFormViewModel vm;

  @override
  String get value => widget.valueBuilder(vm);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVm = context.read<HabitFormViewModel>();
    if (!controllerInitialized || !identical(vm, newVm)) {
      vm = newVm;
    }
    ensureControllerInitialized();
  }

  @override
  void didUpdateWidget(HabitEditFormInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    ensureControllerUpdated(oldWidget);
    if (oldWidget.valueBuilder != widget.valueBuilder) {
      final newText = value;
      if (controller.text != newText) controller.text = newText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller, widget.child);
  }
}
