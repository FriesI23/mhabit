// Copyright 2024 Fries_I23
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

class ChangeLogsSwitcherTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ChangeLogsSwitcherTile(
      {super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile.adaptive(
      // TODO(INDEV): support l10n
      title: const Text("Collect logs"),
      subtitle: value
          ? const Text("Tap to stop logging collection")
          : const Text("Tap to start logging collection"),
      thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
        (states) {
          if (states.contains(MaterialState.selected)) {
            return Icon(
              Icons.pause,
              color: theme.colorScheme.onError,
            );
          }
          return null;
        },
      ),
      activeColor: theme.colorScheme.error,
      value: value,
      onChanged: onChanged,
    );
  }
}
