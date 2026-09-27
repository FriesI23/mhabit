import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('AppleSystemVersion', () {
    test('parses and normalizes one to three numeric components', () {
      expect(AppleSystemVersion.tryParse('27'), const AppleSystemVersion(27));
      expect(
        AppleSystemVersion.tryParse('27.1'),
        const AppleSystemVersion(27, 1),
      );
      expect(
        AppleSystemVersion.tryParse('26.4.1'),
        const AppleSystemVersion(26, 4, 1),
      );
      expect(
        AppleSystemVersion.tryParse(' 27.1 '),
        const AppleSystemVersion(27, 1),
      );
    });

    test('rejects empty, malformed, negative, and oversized versions', () {
      expect(AppleSystemVersion.tryParse(''), isNull);
      expect(AppleSystemVersion.tryParse('unknown'), isNull);
      expect(AppleSystemVersion.tryParse('.27'), isNull);
      expect(AppleSystemVersion.tryParse('27.'), isNull);
      expect(AppleSystemVersion.tryParse('-1.0'), isNull);
      expect(AppleSystemVersion.tryParse('27.0.0.1'), isNull);
    });

    test('compares major, minor, and patch components in order', () {
      expect(
        const AppleSystemVersion(27),
        greaterThan(const AppleSystemVersion(26, 9, 9)),
      );
      expect(
        const AppleSystemVersion(27, 1),
        greaterThan(const AppleSystemVersion(27, 0, 9)),
      );
      expect(
        const AppleSystemVersion(27, 1, 1),
        greaterThan(const AppleSystemVersion(27, 1)),
      );
    });

    test('parses a decorated macOS operating-system version', () {
      expect(
        AppleSystemVersion.tryParseOperatingSystemVersion(
          'Version 27.0.1 (Build 26A123)',
        ),
        const AppleSystemVersion(27, 0, 1),
      );
      expect(
        AppleSystemVersion.tryParseOperatingSystemVersion('unknown'),
        isNull,
      );
    });
  });

  group('AppleSidebarStyle.from', () {
    test('falls back to inset without a usable system version', () {
      expect(AppleSidebarStyle.from(null), AppleSidebarStyle.inset);
      expect(
        AppleSidebarStyle.from(const AppleSystemVersion(26, 9, 9)),
        AppleSidebarStyle.inset,
      );
    });

    test('selects edge from Apple OS 27 onward', () {
      expect(
        AppleSidebarStyle.from(const AppleSystemVersion(27)),
        AppleSidebarStyle.edge,
      );
      expect(
        AppleSidebarStyle.from(const AppleSystemVersion(28)),
        AppleSidebarStyle.edge,
      );
    });
  });
}
