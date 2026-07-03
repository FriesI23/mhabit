// Copyright 2026 Fries_I23
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/pages/app_changelog/changelog_parser.dart';

const _sampleChangelog = '''
# Change log

[中文](./docs/CHANGELOG/zh.md)

## 1.25.3+168

- Update Hebrew translation, thanks to Omer I.S.'s contribution on Weblate (#589)
- Update Turkish translation, thanks to Oğuz Ersen's contribution on Weblate (#589)
- Add automated store submission pipelines (#590, #591, #592, #593)

## 1.25.1+164

- Feature: add per-habit custom color support with built-in swatches, color picker, and recent-color history (#580)

## 1.24.5+161

- Refactor page wiring, tidy unit tests, and simplify habit summary helpers (#563, #571)
- Refactor reminder handling to improve stability on app start, restart, and day changes (#569)
- Improve custom color palette with mhabit_color_builder (#572)
- Fix duplicate habit detail refresh on back navigation (#565)

## 1.24.4+160-pre

- Test pre-release entry

## 1.24.3+159

- Some change

## 1.0.1

- Item one

## 1.0.0

- Initial release
''';

const _sparseChangelog = '''
## 1.0.0

## 1.0.1

- Item after empty section
''';

void main() {
  group('extractVersionSection', () {
    // 1: Normal extraction with 3 bullets (real 1.25.3+168)
    test('extracts version with 3 bullets', () {
      final result = extractVersionSection(_sampleChangelog, '1.25.3+168');
      expect(result, isNotNull);
      expect(result!, contains('- Update Hebrew translation'));
      expect(result, contains('- Update Turkish translation'));
      expect(result, contains('- Add automated store submission pipelines'));
    });

    // 2: Section containing "Feature:" prefix
    test('extracts version with Feature prefix', () {
      final result = extractVersionSection(_sampleChangelog, '1.25.1+164');
      expect(result, isNotNull);
      expect(result!, contains('Feature: add per-habit custom color'));
    });

    // 3: Section with 4+ bullets
    test('extracts version with multiple bullets', () {
      final result = extractVersionSection(_sampleChangelog, '1.24.5+161');
      expect(result, isNotNull);
      expect(result!, contains('- Refactor page wiring'));
      expect(result, contains('- Refactor reminder handling'));
      expect(result, contains('- Improve custom color palette'));
      expect(result, contains('- Fix duplicate habit detail refresh'));
    });

    // 4: Pre-release version
    test('extracts pre-release version', () {
      final result = extractVersionSection(_sampleChangelog, '1.24.4+160-pre');
      expect(result, isNotNull);
      expect(result!, contains('- Test pre-release entry'));
    });

    // 5: Non-existent version
    test('returns null for non-existent version', () {
      final result = extractVersionSection(_sampleChangelog, '99.99.99+999');
      expect(result, isNull);
    });

    // 6: Last entry in file
    test('extracts last entry to EOF', () {
      final result = extractVersionSection(_sampleChangelog, '1.0.0');
      expect(result, isNotNull);
      expect(result!, contains('- Initial release'));
    });

    // 7: Empty section body
    test('returns empty string for empty section body', () {
      final result = extractVersionSection(_sparseChangelog, '1.0.0');
      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    // 8: Section with blank lines preserved
    test('preserves blank lines between paragraphs', () {
      const content = '''
## 1.0.0

First paragraph.

Second paragraph.
''';
      final result = extractVersionSection(content, '1.0.0');
      expect(result, isNotNull);
      expect(result, contains('First paragraph.'));
      expect(result, contains('Second paragraph.'));
    });

    // 9: Inline format round-trip
    test('round-trips inline formatting', () {
      const content = '''
## 1.0.0

- **bold** text and *italic* style with [a link](https://example.com) and `code`
''';
      final result = extractVersionSection(content, '1.0.0');
      expect(result, isNotNull);
      expect(result!, contains('**bold**'));
      expect(result, contains('*italic*'));
      expect(result, contains('[a link](https://example.com)'));
      expect(result, contains('`code`'));
    });

    // 10: Does not match h1 heading
    test('does not match h1 heading', () {
      const content = '''
# 1.0.0

- This is under h1
''';
      final result = extractVersionSection(content, '1.0.0');
      expect(result, isNull);
    });

    // 11: Only bullets, no heading
    test('extracts bullet list section content', () {
      const content = '''
## 1.0.0

- Item one
- Item two
''';
      final result = extractVersionSection(content, '1.0.0');
      expect(result, isNotNull);
      expect(result!, contains('- Item one'));
      expect(result, contains('- Item two'));
    });
  });
}
