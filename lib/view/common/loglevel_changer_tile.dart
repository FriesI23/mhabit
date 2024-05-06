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

import '../../logging/level.dart';

class LogLevelChangerTile extends StatelessWidget {
  final LogLevel crtLevel;
  final void Function(LogLevel newLevel)? onSelected;

  const LogLevelChangerTile({
    super.key,
    required this.crtLevel,
    this.onSelected,
  });

  String _getLogName(BuildContext context, {LogLevel? level}) {
    switch (level ?? crtLevel) {
      case LogLevel.debug:
        return "Debug";
      case LogLevel.info:
        return "Info";
      case LogLevel.warn:
        return "Warn";
      case LogLevel.error:
        return "Error";
      case LogLevel.fatal:
        return "Fatal";
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO(INDEV): support l10n
    Widget buildLogLevelOption(BuildContext context, LogLevel level) {
      return SimpleDialogOption(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_getLogName(context, level: level)),
            if (crtLevel == level) const Icon(Icons.check),
          ],
        ),
        onPressed: () {
          onSelected?.call(level);
          Navigator.of(context).maybePop();
        },
      );
    }

    return ListTile(
      title: const Text("Logging level"),
      subtitle: Text(_getLogName(context)),
      onTap: () => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text("Change logging level"),
          children: [
            buildLogLevelOption(context, LogLevel.debug),
            buildLogLevelOption(context, LogLevel.info),
            buildLogLevelOption(context, LogLevel.warn),
            buildLogLevelOption(context, LogLevel.error),
            buildLogLevelOption(context, LogLevel.fatal),
          ],
        ),
      ),
    );
  }
}
