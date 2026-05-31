import 'dart:async';

import 'package:mhabit/logging/logger_manager.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  AppLoggerMananger(t: AppLoggerHandlerType.custom);
  await testMain();
}
