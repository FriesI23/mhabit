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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../component/widget.dart';
import '../../extension/async_extensions.dart';
import '../../l10n/localizations.dart';
import '../../logging/helper.dart';
import '../../model/app_sync_server.dart';
import '../../provider/app_sync_server_form.dart';

class AppSyncServerPasswordTile extends StatelessWidget {
  const AppSyncServerPasswordTile({super.key});

  Widget _buildSnapshotWidget(BuildContext context,
      AsyncSnapshot<(String, String?)> snapshot, String identity) {
    if (snapshot.hasError || (snapshot.isDone && !snapshot.hasData)) {
      if (kDebugMode) {
        throw Error.throwWithStackTrace(snapshot.error!, snapshot.stackTrace!);
      }
      return AppSyncServerPasswordField(enabled: false, loading: false);
    }
    if (snapshot.isDone) {
      if (snapshot.data?.$1 != identity) {
        return AppSyncServerPasswordField(loading: false, enabled: false);
      }
      return Selector<AppSyncServerFormViewModel, TextEditingController>(
          selector: (context, vm) => vm.passwordInputController,
          builder: (context, value, child) =>
              AppSyncServerPasswordField(controller: value));
    }
    return AppSyncServerPasswordField(
        enabled: false, loading: !snapshot.isDone);
  }

  @override
  Widget build(BuildContext context) {
    final identity =
        context.select<AppSyncServerFormViewModel, String>((vm) => vm.identity);
    final type = context
        .select<AppSyncServerFormViewModel, AppSyncServerType>((vm) => vm.type);
    final vm = context.read<AppSyncServerFormViewModel>();
    return Visibility(
      visible: type.includePasswordField,
      child: FutureBuilder(
        future: vm.getPassword(),
        builder: (context, snapshot) => Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            AnimatedOpacity(
              opacity: (snapshot.isDone || vm.pwdLoaded) ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: const Padding(
                  padding: kListTileContentPadding,
                  child: LinearProgressIndicator()),
            ),
            _buildSnapshotWidget(context, snapshot, identity),
          ],
        ),
      ),
    );
  }
}

class AppSyncServerPasswordField extends StatefulWidget {
  final EdgeInsetsGeometry? contentPadding;
  final bool loading;
  final bool enabled;
  final TextEditingController? controller;

  const AppSyncServerPasswordField({
    super.key,
    this.contentPadding,
    this.loading = false,
    this.enabled = true,
    this.controller,
  });

  @override
  State<AppSyncServerPasswordField> createState() =>
      _AppSyncServerPasswordField();
}

class _AppSyncServerPasswordField extends State<AppSyncServerPasswordField> {
  late bool showPassword;
  late FocusNode _focusNode;
  late final UniqueKey _debugId;

  _AppSyncServerPasswordField() {
    _debugId = UniqueKey();
  }

  @override
  void initState() {
    appLog.build.debug(context, ex: [
      "init[$_debugId]",
      widget.enabled,
      widget.loading,
      widget.controller,
      widget.contentPadding
    ]);
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
    appLog.build.debug(context, ex: [
      "dispose[$_debugId]",
      widget.enabled,
      widget.loading,
      widget.controller,
      widget.contentPadding
    ]);
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return ListTile(
      contentPadding: widget.contentPadding,
      trailing: IconButton(
          onPressed: () => setState(() => showPassword = !showPassword),
          icon: showPassword
              ? const Icon(Icons.visibility_off)
              : const Icon(Icons.visibility)),
      title: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          icon: const Icon(MdiIcons.formTextboxPassword),
          labelText:
              l10n?.appSync_serverEditor_passwordTile_titleText ?? 'Password',
        ),
        obscureText: !showPassword,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        focusNode: _focusNode,
        enabled: widget.enabled,
        onChanged: (_) =>
            context.read<AppSyncServerFormViewModel>().refreshCanSaveStatus(),
      ),
    );
  }
}
