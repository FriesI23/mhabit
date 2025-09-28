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

import '../../l10n/localizations.dart';
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
    final l10n = L10n.of(context);
    switch (level ?? crtLevel) {
      case LogLevel.debug:
        return l10n?.debug_logLevel_debug ?? "Debug";
      case LogLevel.info:
        return l10n?.debug_logLevel_info ?? "Info";
      case LogLevel.warn:
        return l10n?.debug_logLevel_warn ?? "Warn";
      case LogLevel.error:
        return l10n?.debug_logLevel_error ?? "Error";
      case LogLevel.fatal:
        return l10n?.debug_logLevel_fatal ?? "Fatal";
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final l10n = L10n.of(context);
    return ListTile(
      title: l10n != null
          ? Text(l10n.debug_logLevelTile_title)
          : const Text("Logging level"),
      subtitle: Text(_getLogName(context)),
      onTap: () => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: l10n != null
              ? Text(l10n.debug_logLevelDialog_title)
              : const Text("Change logging level"),
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
