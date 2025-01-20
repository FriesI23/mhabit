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

import '../../model/app_sync_server.dart';
import '../../provider/app_sync_server_form.dart';

class AppSyncServerUsernameTile extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerUsernameTile({
    super.key,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final type = context
        .select<AppSyncServerFormViewModel, AppSyncServerType>((vm) => vm.type);
    final controller =
        context.select<AppSyncServerFormViewModel, TextEditingController>(
            (vm) => vm.usernameInputController);
    return Offstage(
      offstage: !type.includePathField,
      child: ListTile(
        contentPadding: contentPadding,
        title: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Enter username here, leave empty if not required.',
          ),
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }
}

class AppSyncServerPasswordTile extends StatefulWidget {
  final EdgeInsetsGeometry? contentPadding;

  const AppSyncServerPasswordTile({
    super.key,
    this.contentPadding,
  });

  @override
  State<AppSyncServerPasswordTile> createState() =>
      _AppSyncServerPasswordTile();
}

class _AppSyncServerPasswordTile extends State<AppSyncServerPasswordTile> {
  late bool showPassword;
  late FocusNode _focusNode;

  _AppSyncServerPasswordTile();

  @override
  void initState() {
    showPassword = false;
    _focusNode = FocusNode();
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !showPassword) {
        final controller =
            context.read<AppSyncServerFormViewModel>().passwordInputController;
        controller.selection =
            TextSelection(baseOffset: 0, extentOffset: controller.text.length);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = context
        .select<AppSyncServerFormViewModel, AppSyncServerType>((vm) => vm.type);
    final controller =
        context.select<AppSyncServerFormViewModel, TextEditingController>(
            (vm) => vm.passwordInputController);
    return Offstage(
      offstage: !type.includePathField,
      child: ListTile(
        contentPadding: widget.contentPadding,
        trailing: IconButton(
            onPressed: () => setState(() => showPassword = !showPassword),
            icon: showPassword
                ? const Icon(Icons.visibility_off)
                : const Icon(Icons.visibility)),
        title: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: !showPassword,
          enableSuggestions: false,
          autocorrect: false,
          keyboardType: TextInputType.visiblePassword,
          focusNode: _focusNode,
        ),
      ),
    );
  }
}
