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

// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:mhabit/utils/async_debouncer.dart';
import 'package:test/test.dart';

void main() {
  group('test CascadingAsyncDebouncer', () {
    late List<String> records;
    late CascadingAsyncDebouncer debouncer;

    setUp(() {
      records = [];
      debouncer = CascadingAsyncDebouncer(
        action: () async {
          records.add('executed');
          await Future.delayed(Duration(milliseconds: 50));
        },
      );
    });

    test('exec executes the action after delay', () async {
      debouncer.exec(delay: Duration(milliseconds: 20));
      expect(records, isEmpty);
      await Future.delayed(Duration(milliseconds: 30));
      expect(records, ['executed']);
    });

    test('exec with zero delay executes immediately', () async {
      debouncer.exec();
      await Future.delayed(Duration(milliseconds: 10));
      expect(records, ['executed']);
    });

    test('exec called multiple times only executes once if not running',
        () async {
      debouncer.exec(delay: Duration(milliseconds: 50));
      debouncer.exec(delay: Duration(milliseconds: 10));
      debouncer.exec(delay: Duration(milliseconds: 20));
      await Future.delayed(Duration(milliseconds: 60));
      expect(records, ['executed']);
    });

    test('exec while executing queues the next one', () async {
      debouncer.exec(delay: Duration(milliseconds: 10));
      await Future.delayed(Duration(milliseconds: 15));
      // queued during execution
      debouncer.exec(delay: Duration(milliseconds: 10));
      // enough to complete both
      await Future.delayed(Duration(milliseconds: 100));
      expect(records, ['executed', 'executed']);
    });

    test('cancel prevents future execution', () async {
      debouncer.exec(delay: Duration(milliseconds: 30));
      debouncer.cancel();
      await Future.delayed(Duration(milliseconds: 50));
      expect(records, isEmpty);
    });

    test('cancel does not stop a running action', () async {
      debouncer.exec(delay: Duration(milliseconds: 5));
      await Future.delayed(Duration(milliseconds: 10));
      debouncer.cancel();
      await Future.delayed(Duration(milliseconds: 60));
      expect(records, ['executed']);
    });

    test('isRunning reflects state correctly', () async {
      expect(debouncer.isRunning, isFalse);
      debouncer.exec(delay: Duration(milliseconds: 10));
      expect(debouncer.isRunning, isTrue);
      await Future.delayed(Duration(milliseconds: 15));
      expect(debouncer.isRunning, isTrue);
      await Future.delayed(Duration(milliseconds: 100));
      expect(debouncer.isRunning, isFalse);
    });
  });
}
