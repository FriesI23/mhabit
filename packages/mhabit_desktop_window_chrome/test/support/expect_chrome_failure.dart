import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures an intentional fallback diagnostic while retaining other output.
/// Unexpected or missing failures still fail the calling test.
Future<void> expectChromeFailure(
  Future<void> Function() action,
  String expectedError,
) async {
  const prefix = 'Desktop window fusion unavailable: ';
  final messages = <String>[];
  final previousDebugPrint = debugPrint;
  debugPrint = (message, {wrapWidth}) {
    if (message != null && message.startsWith(prefix)) {
      messages.add(message);
    } else {
      previousDebugPrint(message, wrapWidth: wrapWidth);
    }
  };
  try {
    await action();
  } finally {
    debugPrint = previousDebugPrint;
  }
  expect(messages, hasLength(1));
  expect(messages.single, startsWith('$prefix$expectedError\n'));
}
