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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../common/app_info.dart';
import '../../extension/navigator_extensions.dart';
import '../../utils/app_path_provider.dart';
import '../../widgets/helpers.dart';
import '../../widgets/widgets.dart';

class AppErrorPage extends StatelessWidget {
  final FlutterErrorDetails details;
  final int lastLogLines;
  final bool showCloseBtn;

  const AppErrorPage({
    super.key,
    required this.details,
    this.lastLogLines = 200,
    this.showCloseBtn = true,
  });

  void onPressFAB(BuildContext context) async {
    final sb = StringBuffer();

    void writeDivider({int flag = 0}) {
      sb.write(switch (flag) {
        (0) => "│",
        (1) => "┌",
        (2) => "└",
        (_) => "─",
      });
      sb.writeln('─' * 53);
    }

    sb.writeln(await AppInfo().generateAppDebugInfo());
    writeDivider(flag: 1);
    sb.writeln(details.exception.toString());
    sb.writeln("Crash date: ${DateTime.now()}");
    writeDivider();
    sb.write(details.stack.toString());
    writeDivider(flag: 2);

    sb.writeln();

    writeDivider(flag: 1);
    sb.writeln("Last $lastLogLines logs");
    writeDivider();
    final file = File(await AppPathProvider().getAppDebugLogFilePath());
    sb.writeAll(
        await file
            .exists()
            .then((value) =>
                value ? file.readAsLines() : Future.value(const <String>[]))
            .then((value) => value.length <= lastLogLines
                ? value
                : value.sublist(value.length - lastLogLines)),
        '\n');
    sb.writeln();
    writeDivider(flag: 2);

    Clipboard.setData(ClipboardData(text: sb.toString())).then((value) {
      if (!context.mounted) return;
      final snackBar = buildSnackBarWithDismiss(context,
          content: L10nBuilder(
              builder: (context, l10n) =>
                  Text(l10n?.common_errorPage_copied ?? 'Copied')),
          duration: const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.copy),
        onPressed: () => onPressFAB(context),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: L10nBuilder(
              builder: (context, l10n) => Text(
                  l10n?.common_errorPage_title ?? "Unhandled Exception",
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
            leading: Visibility(
              visible: showCloseBtn,
              child: PageBackButton(
                reason: PageBackReason.close,
                onPressed: () =>
                    Navigator.maybeOf(context)?.popOrExit() ??
                    SystemNavigator.pop(),
              ),
            ),
            centerTitle: true,
            pinned: true,
          ),
          SliverPinnedHeader(
            child: ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(title: Text(details.exception.toString()))),
          ),
          const SliverToBoxAdapter(child: Divider()),
          SliverToBoxAdapter(
              child: ListTile(
            subtitle: Text(details.stack.toString()),
            isThreeLine: true,
          )),
          const SliverToBoxAdapter(child: SizedBox(height: 200)),
        ],
      ),
    );
  }
}
