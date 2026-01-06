// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

Future<AppSettingConfirmClearDBOp?> showAppSettingConfirmClearDBDiloag({
  required BuildContext context,
}) async {
  return showDialog<AppSettingConfirmClearDBOp>(
    context: context,
    builder: (context) => const AppSettingConfirmClearDBDiloag(),
  );
}

enum AppSettingConfirmClearDBOp { cancel, confirm, confirmWithExport }

class AppSettingConfirmClearDBDiloag extends StatefulWidget {
  const AppSettingConfirmClearDBDiloag({super.key});

  @override
  State<StatefulWidget> createState() => _AppSettingConfirmClearDBDiloag();
}

class _AppSettingConfirmClearDBDiloag
    extends State<AppSettingConfirmClearDBDiloag> {
  bool checked = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm"),
      content: CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text("backup first"),
        value: checked,
        onChanged: (value) => setState(() {
          checked = !checked;
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.maybeOf(
            context,
          )?.maybePop(AppSettingConfirmClearDBOp.cancel),
          child: const Text("cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.maybeOf(context)?.maybePop(
            checked
                ? AppSettingConfirmClearDBOp.confirmWithExport
                : AppSettingConfirmClearDBOp.confirm,
          ),
          child: const Text("confirm"),
        ),
      ],
    );
  }
}
