import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

void main() {
  group('IosSystemVersion', () {
    test('parses and normalizes one to three numeric components', () {
      expect(IosSystemVersion.tryParse('27'), const IosSystemVersion(27));
      expect(IosSystemVersion.tryParse('27.1'), const IosSystemVersion(27, 1));
      expect(
        IosSystemVersion.tryParse('26.4.1'),
        const IosSystemVersion(26, 4, 1),
      );
      expect(
        IosSystemVersion.tryParse(' 27.1 '),
        const IosSystemVersion(27, 1),
      );
    });

    test('rejects empty, malformed, negative, and oversized versions', () {
      expect(IosSystemVersion.tryParse(''), isNull);
      expect(IosSystemVersion.tryParse('unknown'), isNull);
      expect(IosSystemVersion.tryParse('.27'), isNull);
      expect(IosSystemVersion.tryParse('27.'), isNull);
      expect(IosSystemVersion.tryParse('-1.0'), isNull);
      expect(IosSystemVersion.tryParse('27.0.0.1'), isNull);
    });

    test('compares major, minor, and patch components in order', () {
      expect(
        const IosSystemVersion(27),
        greaterThan(const IosSystemVersion(26, 9, 9)),
      );
      expect(
        const IosSystemVersion(27, 1),
        greaterThan(const IosSystemVersion(27, 0, 9)),
      );
      expect(
        const IosSystemVersion(27, 1, 1),
        greaterThan(const IosSystemVersion(27, 1)),
      );
    });
  });

  group('AppleSidebarStyle.from', () {
    test('falls back to inset without a usable system version', () {
      expect(AppleSidebarStyle.from(null), AppleSidebarStyle.inset);
      expect(
        AppleSidebarStyle.from(const IosSystemVersion(26, 9, 9)),
        AppleSidebarStyle.inset,
      );
    });

    test('selects edge from iOS and iPadOS 27 onward', () {
      expect(
        AppleSidebarStyle.from(const IosSystemVersion(27)),
        AppleSidebarStyle.edge,
      );
      expect(
        AppleSidebarStyle.from(const IosSystemVersion(28)),
        AppleSidebarStyle.edge,
      );
    });
  });
}
