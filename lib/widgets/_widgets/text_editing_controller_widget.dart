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

abstract class BaseTextEditingControllerWidget extends StatefulWidget {
  final TextEditingController? controller;

  const BaseTextEditingControllerWidget({super.key, this.controller});

  @override
  State<BaseTextEditingControllerWidget> createState();
}

abstract class BaseTextEditingControllerWidgetState<
  S extends BaseTextEditingControllerWidget
>
    extends State<S> {
  late TextEditingController controller;
  bool _controllerInitialized = false;

  String get value;

  bool get controllerInitialized => _controllerInitialized;

  void ensureControllerInitialized() {
    if (_controllerInitialized) return;
    if (widget.controller != null) {
      controller = widget.controller!;
      if (controller.text != value) controller.text = value;
    } else {
      controller = TextEditingController(text: value);
    }
    _controllerInitialized = true;
  }

  void ensureControllerUpdated(S oldWidget, {bool force = false}) {
    if (oldWidget.controller != widget.controller || force) {
      final oldController = controller;
      if (widget.controller != null) {
        controller = widget.controller!;
        if (controller.text != value) controller.text = value;
      } else {
        controller = TextEditingController(text: value);
      }
      if (oldWidget.controller == null) oldController.dispose();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }
}

class SingleTextFormInputField<T> extends BaseTextEditingControllerWidget {
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    Widget? child,
  )
  builder;
  final String Function(T vm) valueBuilder;
  final Widget? child;

  const SingleTextFormInputField({
    super.key,
    super.controller,
    required this.builder,
    required this.valueBuilder,
    this.child,
  });

  @override
  State<BaseTextEditingControllerWidget> createState() =>
      _SingleTextFormInputFieldState<T>();
}

class _SingleTextFormInputFieldState<T>
    extends BaseTextEditingControllerWidgetState<SingleTextFormInputField<T>> {
  late T vm;

  @override
  String get value => widget.valueBuilder(vm);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newVm = context.read<T>();
    if (!controllerInitialized || !identical(vm, newVm)) {
      vm = newVm;
    }
    ensureControllerInitialized();
  }

  @override
  void didUpdateWidget(SingleTextFormInputField<T> oldWidget) {
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
