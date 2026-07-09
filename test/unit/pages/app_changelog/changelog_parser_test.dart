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
  group('extractVersionSectionWithFallback', () {
    // 12: Stable code version → beta CHANGELOG heading
    //     (e.g. PackageInfo reports "1.25.4+169" but CHANGELOG has "1.25.4+169-pre")
    test('matches beta heading from stable code version', () {
      const content = '''
## 1.25.4+169-pre

- Pre-release feature A
- Pre-release feature B

## 1.25.3+168

- Stable release
''';
      final result = extractVersionSectionWithFallback(content, '1.25.4+169');
      expect(result, isNotNull);
      expect(result!, contains('- Pre-release feature A'));
      expect(result, contains('- Pre-release feature B'));
      expect(result, isNot(contains('- Stable release')));
    });

    // 13: Beta code version → stable CHANGELOG heading
    //     (e.g. flavor suffix "-dev" stripped to match base version)
    test('matches stable heading from beta code version', () {
      const content = '''
## 1.25.4+169

- Stable feature

## 1.25.3+168

- Older release
''';
      final result = extractVersionSectionWithFallback(
        content,
        '1.25.4-dev+169',
      );
      expect(result, isNotNull);
      expect(result!, contains('- Stable feature'));
    });

    // 14: Exact match still works
    test('exact match preferred over fallback', () {
      const content = '''
## 1.25.4+169

- Exact match content

## 1.25.4+169-pre

- Pre-release content
''';
      final result = extractVersionSectionWithFallback(content, '1.25.4+169');
      expect(result, isNotNull);
      expect(result!, contains('- Exact match content'));
      expect(result, isNot(contains('- Pre-release content')));
    });

    // 15: Latest-section fallback when no heading matches
    test('falls back to latest section when no heading matches', () {
      const content = '''
## 1.25.3+168

- Only old version
''';
      // 1.25.4+169 doesn't exist → falls back to latest (1.25.3+168)
      final result = extractVersionSectionWithFallback(
        content,
        '1.25.4+169',
        useLatestFallback: true,
      );
      expect(result, isNotNull);
      expect(result!, contains('- Only old version'));
    });

    // 16: Beta heading with multi-hyphen suffix (e.g. -pre-release)
    //     Regression: old \w+ regex failed on suffixes containing '-'
    test('matches beta heading with multi-hyphen suffix', () {
      const content = '''
## 1.25.5+170-pre-release

- Multi-hyphen suffix content
''';
      final result = extractVersionSectionWithFallback(content, '1.25.5+170');
      expect(result, isNotNull);
      expect(result!, contains('- Multi-hyphen suffix content'));
    });

    // 17: Beta heading with dotted suffix (e.g. -rc.1)
    //     Regression: old \w+ regex failed on suffixes containing '.'
    test('matches beta heading with dotted suffix', () {
      const content = '''
## 1.25.5+170-rc.1

- Release candidate content
''';
      final result = extractVersionSectionWithFallback(content, '1.25.5+170');
      expect(result, isNotNull);
      expect(result!, contains('- Release candidate content'));
    });

    // 18: Chinese preamble with ASCII version headings
    //     Simulates zh.md: h1 in Chinese + CHANGELOG link before first h2
    test('matches version with Chinese preamble and CHANGELOG link', () {
      const content = '''
# 更新日志

[中文](./docs/CHANGELOG/zh.md)

## 1.25.5+170-pre

- 功能：实现自适应内容面板

## 1.25.4+169-pre

- 旧版本内容
''';
      final result = extractVersionSectionWithFallback(content, '1.25.5+170');
      expect(result, isNotNull);
      expect(result!, contains('- 功能：实现自适应内容面板'));
      expect(result, isNot(contains('- 旧版本内容')));
    });

    // 19: Semver-only fallback — wrong build number (e.g. F-Droid prefix)
    //     1.25.5+2170 → no heading matches → falls through to semver "1.25.5"
    test('matches by semver when build number has wrong prefix', () {
      const content = '''
## 1.25.5+170-pre

- 功能：自适应内容面板
''';
      final result = extractVersionSectionWithFallback(content, '1.25.5+2170');
      expect(result, isNotNull);
      expect(result!, contains('- 功能：自适应内容面板'));
    });

    // 20: Semver fallback versus pre-release heading
    test('matches by semver against pre-release heading', () {
      const content = '''
## 1.25.5+170-pre

- Pre-release content
''';
      final result = extractVersionSectionWithFallback(content, '1.25.5+9999');
      expect(result, isNotNull);
      expect(result!, contains('- Pre-release content'));
    });

    // 21: Exact match is still preferred (even with semver fallback available)
    test('exact match preferred over semver fallback', () {
      const content = '''
## 1.25.5+170

- Exact match content

## 1.25.5+170-pre

- Pre-release content
''';
      final result = extractVersionSectionWithFallback(content, '1.25.5+170');
      expect(result, isNotNull);
      expect(result!, contains('- Exact match content'));
      expect(result, isNot(contains('- Pre-release content')));
    });

    // 22: Flavor suffix + wrong build number → semver fallback
    //     1.25.4-dev+2170 → base 1.25.4+2170 → semver 1.25.4 → match 1.25.4+169
    test('strips flavor suffix before semver fallback', () {
      const content = '''
## 1.25.4+169

- Content for 169
''';
      final result = extractVersionSectionWithFallback(
        content,
        '1.25.4-dev+2170',
      );
      expect(result, isNotNull);
      expect(result!, contains('- Content for 169'));
    });

    // 23: Semver fallback returns null, but latest-section fallback kicks in
    test('falls back to latest section when no heading matches at all', () {
      const content = '''
## 1.25.5+170

- Some content

## 1.25.4+169

- Older content
''';
      final result = extractVersionSectionWithFallback(
        content,
        '2.0.0',
        useLatestFallback: true,
      );
      expect(result, isNotNull);
      expect(result!, contains('- Some content'));
      expect(result, isNot(contains('- Older content')));
    });

    // 24: Latest-section fallback with content containing only one heading
    test(
      'returns only section when content has a single heading and no match',
      () {
        const content = '''
## 1.25.5+170

- Lone section
''';
        final result = extractVersionSectionWithFallback(
          content,
          '9.9.9+9',
          useLatestFallback: true,
        );
        expect(result, isNotNull);
        expect(result!, contains('- Lone section'));
      },
    );
  });

  group('parseChangelogSections', () {
    // 16: Parses all sections from sample changelog
    test('parses all sections from sample changelog', () {
      final sections = parseChangelogSections(_sampleChangelog);
      expect(sections.length, 7);
      expect(sections[0].version, '1.25.3+168');
      expect(sections[0].body, contains('- Update Hebrew translation'));
      expect(sections[1].version, '1.25.1+164');
      expect(sections[2].version, '1.24.5+161');
      expect(sections[3].version, '1.24.4+160-pre');
      expect(sections[4].version, '1.24.3+159');
      expect(sections[5].version, '1.0.1');
      expect(sections[6].version, '1.0.0');
    });

    // 17: Handles empty body sections
    test('handles empty body sections', () {
      final sections = parseChangelogSections(_sparseChangelog);
      expect(sections.length, 2);
      expect(sections[0].version, '1.0.0');
      expect(sections[0].body, isEmpty);
      expect(sections[1].version, '1.0.1');
      expect(sections[1].body, isNotEmpty);
    });

    // 18: Returns empty list for content without h2 headings
    test('returns empty list for content without h2 headings', () {
      const content = '# Only h1\n\n- item';
      final sections = parseChangelogSections(content);
      expect(sections, isEmpty);
    });
  });
}
