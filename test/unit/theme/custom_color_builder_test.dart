// Copyright 2026 Fries_I23
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

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:mhabit_color_builder/custom_color_builder.dart';
import 'package:test/test.dart';

void main() {
  group('generateCustomColorPartFromPubspec', () {
    test('uses code defaults when primary tuning is omitted', () {
      final output = generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  app:
    colors:
      cc1: '0xFF6750A4'
      cc2: '0xFFF44336'
''', configName: 'app');

      final explicitDefaultOutput = generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  app:
    light_primary_min_chroma: 48
    dark_primary_min_chroma: 48
    light_primary_tone: 56
    dark_primary_tone: 80
    colors:
      cc1: '0xFF6750A4'
      cc2: '0xFFF44336'
''', configName: 'app');

      final parseResult = parseString(
        content:
            '''
import 'package:flutter/material.dart';

$output
''',
        throwIfDiagnostics: false,
      );

      expect(parseResult.errors, isEmpty);
      expect(output, explicitDefaultOutput);
      expect(output, contains('// ignore_for_file: type=lint'));
      expect(
        output,
        contains('// Source: pubspec.yaml > mhabit_color_builder["app"]'),
      );
      expect(output, contains('const cc1 = Color(0xFF6750A4);'));
      expect(output, contains('const cc2 = Color(0xFFF44336);'));
      expect(output, contains('CustomColors lightCustomColors'));
      expect(output, contains('CustomColors darkCustomColors'));
      expect(output, isNot(contains('modifedLightCustomColors')));
      expect(
        output,
        contains(
          '/// Defines a set of custom colors, each comprised of 4 complementary tones.',
        ),
      );
      expect(
        output,
        contains('/// Returns a copy of this [CustomColors] instance.'),
      );
      expect(
        output,
        contains(
          '/// The generated implementation does not apply harmonization from',
        ),
      );
      expect(output, contains('/// [colorScheme].'));
      expect(
        output,
        contains('class CustomColors extends ThemeExtension<CustomColors>'),
      );
    });

    test(
      'uses primary values as fallback and lets light and dark override them',
      () {
        final output = generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  app:
    primary_min_chroma: 40
    primary_tone: 62
    light_primary_tone: 56
    dark_primary_min_chroma: 52
    colors:
      cc1: '0xFF6750A4'
      cc2: '0xFFF44336'
''', configName: 'app');

        final explicitOutput = generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  app:
    light_primary_min_chroma: 40
    dark_primary_min_chroma: 52
    light_primary_tone: 56
    dark_primary_tone: 62
    colors:
      cc1: '0xFF6750A4'
      cc2: '0xFFF44336'
''', configName: 'app');

        expect(output, explicitOutput);
      },
    );

    test('throws when a tone value is outside 0..100', () {
      expect(
        () => generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  app:
    primary_tone: 101
    colors:
      cc1: '0xFF6750A4'
''', configName: 'app'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Expected mhabit_color_builder["app"]["primary_tone"] to be an integer in 0..100 in pubspec.yaml.',
          ),
        ),
      );
    });

    test('throws when a min chroma value is negative', () {
      expect(
        () => generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  app:
    primary_min_chroma: -1
    colors:
      cc1: '0xFF6750A4'
''', configName: 'app'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Expected mhabit_color_builder["app"]["primary_min_chroma"] to be a finite number >= 0 in pubspec.yaml.',
          ),
        ),
      );
    });

    test('throws when a custom color name is not a valid Dart identifier', () {
      expect(
        () => generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  app:
    colors:
      invalid-name: '0xFF6750A4'
''', configName: 'app'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Expected each custom color name under mhabit_color_builder["app"]["colors"] to be a non-empty valid Dart identifier in pubspec.yaml.',
          ),
        ),
      );
    });

    test('throws when the named pubspec configuration entry is missing', () {
      expect(
        () => generateCustomColorPartFromPubspec('''
mhabit_color_builder:
  other:
    colors:
      cc1: '0xFF6750A4'
''', configName: 'app'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Could not find mhabit_color_builder["app"] in pubspec.yaml.',
          ),
        ),
      );
    });
  });
}
