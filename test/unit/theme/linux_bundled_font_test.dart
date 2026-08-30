import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhabit/theme/linux_bundled_font.dart';

void main() {
  test('does not inspect the bundled font outside Linux', () async {
    var inspectedFile = false;

    final loaded = await loadLinuxBundledFont(
      platform: TargetPlatform.windows,
      fileExists: (_) async {
        inspectedFile = true;
        return true;
      },
    );

    expect(loaded, isFalse);
    expect(inspectedFile, isFalse);
  });

  test(
    'leaves a Linux build unchanged when the Flatpak font is absent',
    () async {
      final loaded = await loadLinuxBundledFont(
        platform: TargetPlatform.linux,
        fileExists: (_) async => false,
      );

      expect(loaded, isFalse);
    },
  );

  test('registers the Flatpak font with Flutter before use', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    String? registeredFamily;
    Uint8List? registeredBytes;

    final loaded = await loadLinuxBundledFont(
      platform: TargetPlatform.linux,
      fileExists: (path) async => path == linuxBundledFontPath,
      readFile: (path) async {
        expect(path, linuxBundledFontPath);
        return bytes;
      },
      registerFont: (fontBytes, family) async {
        registeredBytes = fontBytes;
        registeredFamily = family;
      },
    );

    expect(loaded, isTrue);
    expect(registeredBytes, same(bytes));
    expect(registeredFamily, linuxBundledFontFamily);
  });
}
