// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart' as logger;
import 'package:mhabit/logging/handlers/console_printer.dart';
import 'package:mhabit/logging/logger_manager.dart';

final class _Output extends logger.LogOutput {
  final lines = <String>[];

  @override
  void output(logger.OutputEvent event) => lines.addAll(event.lines);
}

void main() {
  test(
    'home-screen widget messages use a distinct diagnostic category',
    () async {
      final output = _Output();
      final manager = AppLoggerMananger();
      await manager.changeLogger(
        logger.Logger(
          filter: logger.ProductionFilter(),
          printer: const AppLoggerConsoleReleasePrinter(addTime: false),
          output: output,
        ),
      );
      addTearDown(
        () => manager.changeLogger(AppLoggerMananger.buildSilentLogger()),
      );
      output.lines.clear();

      manager.habitWidget.info('native snapshot published');
      manager.habit.info('record changed');

      expect(output.lines, hasLength(2));
      expect(output.lines.first, contains('[app:habitWidget:'));
      expect(output.lines.first, contains('native snapshot published'));
      expect(output.lines.last, contains('[app:habit:'));
      expect(output.lines.last, isNot(contains('[app:habitWidget:')));
    },
  );
}
