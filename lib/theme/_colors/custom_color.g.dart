// ignore_for_file: unused_import

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

const cc1 = Color(0xFF6750A4);
const cc2 = Color(0xFFF44336);
const cc3 = Color(0xFF9C27B0);
const cc4 = Color(0xFF3F51B5);
const cc5 = Color(0xFF009688);
const cc6 = Color(0xFF4CAF50);
const cc7 = Color(0xFFFFC107);
const cc8 = Color(0xFFFF9800);
const cc9 = Color(0xFF8BC34A);
const cc10 = Color(0xFF673AB7);

CustomColors lightCustomColors = const CustomColors(
  sourceCc1: Color(0xFF6750A4),
  cc1: Color(0xFF6750A4),
  onCc1: Color(0xFFFFFFFF),
  cc1Container: Color(0xFFE9DDFF),
  onCc1Container: Color(0xFF22005D),
  sourceCc2: Color(0xFFF44336),
  cc2: Color(0xFFBB1614),
  onCc2: Color(0xFFFFFFFF),
  cc2Container: Color(0xFFFFDAD5),
  onCc2Container: Color(0xFF410001),
  sourceCc3: Color(0xFF9C27B0),
  cc3: Color(0xFF9A25AE),
  onCc3: Color(0xFFFFFFFF),
  cc3Container: Color(0xFFFFD6FE),
  onCc3Container: Color(0xFF35003F),
  sourceCc4: Color(0xFF3F51B5),
  cc4: Color(0xFF4355B9),
  onCc4: Color(0xFFFFFFFF),
  cc4Container: Color(0xFFDEE0FF),
  onCc4Container: Color(0xFF00105C),
  sourceCc5: Color(0xFF009688),
  cc5: Color(0xFF006A60),
  onCc5: Color(0xFFFFFFFF),
  cc5Container: Color(0xFF74F8E5),
  onCc5Container: Color(0xFF00201C),
  sourceCc6: Color(0xFF4CAF50),
  cc6: Color(0xFF006E1C),
  onCc6: Color(0xFFFFFFFF),
  cc6Container: Color(0xFF94F990),
  onCc6Container: Color(0xFF002204),
  sourceCc7: Color(0xFFFFC107),
  cc7: Color(0xFF785900),
  onCc7: Color(0xFFFFFFFF),
  cc7Container: Color(0xFFFFDF9E),
  onCc7Container: Color(0xFF261A00),
  sourceCc8: Color(0xFFFF9800),
  cc8: Color(0xFF8B5000),
  onCc8: Color(0xFFFFFFFF),
  cc8Container: Color(0xFFFFDCBE),
  onCc8Container: Color(0xFF2C1600),
  sourceCc9: Color(0xFF8BC34A),
  cc9: Color(0xFF3E6A00),
  onCc9: Color(0xFFFFFFFF),
  cc9Container: Color(0xFFB9F474),
  onCc9Container: Color(0xFF0F2000),
  sourceCc10: Color(0xFF673AB7),
  cc10: Color(0xFF6F43C0),
  onCc10: Color(0xFFFFFFFF),
  cc10Container: Color(0xFFEBDDFF),
  onCc10Container: Color(0xFF250059),
);

CustomColors darkCustomColors = const CustomColors(
  sourceCc1: Color(0xFF6750A4),
  cc1: Color(0xFFCFBCFF),
  onCc1: Color(0xFF381E72),
  cc1Container: Color(0xFF4F378A),
  onCc1Container: Color(0xFFE9DDFF),
  sourceCc2: Color(0xFFF44336),
  cc2: Color(0xFFFFB4A9),
  onCc2: Color(0xFF690002),
  cc2Container: Color(0xFF930005),
  onCc2Container: Color(0xFFFFDAD5),
  sourceCc3: Color(0xFF9C27B0),
  cc3: Color(0xFFF9ABFF),
  onCc3: Color(0xFF570066),
  cc3Container: Color(0xFF7B008F),
  onCc3Container: Color(0xFFFFD6FE),
  sourceCc4: Color(0xFF3F51B5),
  cc4: Color(0xFFBAC3FF),
  onCc4: Color(0xFF08218A),
  cc4Container: Color(0xFF293CA0),
  onCc4Container: Color(0xFFDEE0FF),
  sourceCc5: Color(0xFF009688),
  cc5: Color(0xFF53DBC9),
  onCc5: Color(0xFF003731),
  cc5Container: Color(0xFF005048),
  onCc5Container: Color(0xFF74F8E5),
  sourceCc6: Color(0xFF4CAF50),
  cc6: Color(0xFF78DC77),
  onCc6: Color(0xFF00390A),
  cc6Container: Color(0xFF005313),
  onCc6Container: Color(0xFF94F990),
  sourceCc7: Color(0xFFFFC107),
  cc7: Color(0xFFFABD00),
  onCc7: Color(0xFF3F2E00),
  cc7Container: Color(0xFF5B4300),
  onCc7Container: Color(0xFFFFDF9E),
  sourceCc8: Color(0xFFFF9800),
  cc8: Color(0xFFFFB870),
  onCc8: Color(0xFF4A2800),
  cc8Container: Color(0xFF693C00),
  onCc8Container: Color(0xFFFFDCBE),
  sourceCc9: Color(0xFF8BC34A),
  cc9: Color(0xFF9ED75B),
  onCc9: Color(0xFF1E3700),
  cc9Container: Color(0xFF2E4F00),
  onCc9Container: Color(0xFFB9F474),
  sourceCc10: Color(0xFF673AB7),
  cc10: Color(0xFFD3BBFF),
  onCc10: Color(0xFF3F008D),
  cc10Container: Color(0xFF5727A6),
  onCc10Container: Color(0xFFEBDDFF),
);

/// Defines a set of custom colors, each comprised of 4 complementary tones.
///
/// See also:
///   * <https://m3.material.io/styles/color/the-color-system/custom-colors>
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.sourceCc1,
    required this.cc1,
    required this.onCc1,
    required this.cc1Container,
    required this.onCc1Container,
    required this.sourceCc2,
    required this.cc2,
    required this.onCc2,
    required this.cc2Container,
    required this.onCc2Container,
    required this.sourceCc3,
    required this.cc3,
    required this.onCc3,
    required this.cc3Container,
    required this.onCc3Container,
    required this.sourceCc4,
    required this.cc4,
    required this.onCc4,
    required this.cc4Container,
    required this.onCc4Container,
    required this.sourceCc5,
    required this.cc5,
    required this.onCc5,
    required this.cc5Container,
    required this.onCc5Container,
    required this.sourceCc6,
    required this.cc6,
    required this.onCc6,
    required this.cc6Container,
    required this.onCc6Container,
    required this.sourceCc7,
    required this.cc7,
    required this.onCc7,
    required this.cc7Container,
    required this.onCc7Container,
    required this.sourceCc8,
    required this.cc8,
    required this.onCc8,
    required this.cc8Container,
    required this.onCc8Container,
    required this.sourceCc9,
    required this.cc9,
    required this.onCc9,
    required this.cc9Container,
    required this.onCc9Container,
    required this.sourceCc10,
    required this.cc10,
    required this.onCc10,
    required this.cc10Container,
    required this.onCc10Container,
  });

  final Color? sourceCc1;
  final Color? cc1;
  final Color? onCc1;
  final Color? cc1Container;
  final Color? onCc1Container;
  final Color? sourceCc2;
  final Color? cc2;
  final Color? onCc2;
  final Color? cc2Container;
  final Color? onCc2Container;
  final Color? sourceCc3;
  final Color? cc3;
  final Color? onCc3;
  final Color? cc3Container;
  final Color? onCc3Container;
  final Color? sourceCc4;
  final Color? cc4;
  final Color? onCc4;
  final Color? cc4Container;
  final Color? onCc4Container;
  final Color? sourceCc5;
  final Color? cc5;
  final Color? onCc5;
  final Color? cc5Container;
  final Color? onCc5Container;
  final Color? sourceCc6;
  final Color? cc6;
  final Color? onCc6;
  final Color? cc6Container;
  final Color? onCc6Container;
  final Color? sourceCc7;
  final Color? cc7;
  final Color? onCc7;
  final Color? cc7Container;
  final Color? onCc7Container;
  final Color? sourceCc8;
  final Color? cc8;
  final Color? onCc8;
  final Color? cc8Container;
  final Color? onCc8Container;
  final Color? sourceCc9;
  final Color? cc9;
  final Color? onCc9;
  final Color? cc9Container;
  final Color? onCc9Container;
  final Color? sourceCc10;
  final Color? cc10;
  final Color? onCc10;
  final Color? cc10Container;
  final Color? onCc10Container;

  @override
  CustomColors copyWith({
    Color? sourceCc1,
    Color? cc1,
    Color? onCc1,
    Color? cc1Container,
    Color? onCc1Container,
    Color? sourceCc2,
    Color? cc2,
    Color? onCc2,
    Color? cc2Container,
    Color? onCc2Container,
    Color? sourceCc3,
    Color? cc3,
    Color? onCc3,
    Color? cc3Container,
    Color? onCc3Container,
    Color? sourceCc4,
    Color? cc4,
    Color? onCc4,
    Color? cc4Container,
    Color? onCc4Container,
    Color? sourceCc5,
    Color? cc5,
    Color? onCc5,
    Color? cc5Container,
    Color? onCc5Container,
    Color? sourceCc6,
    Color? cc6,
    Color? onCc6,
    Color? cc6Container,
    Color? onCc6Container,
    Color? sourceCc7,
    Color? cc7,
    Color? onCc7,
    Color? cc7Container,
    Color? onCc7Container,
    Color? sourceCc8,
    Color? cc8,
    Color? onCc8,
    Color? cc8Container,
    Color? onCc8Container,
    Color? sourceCc9,
    Color? cc9,
    Color? onCc9,
    Color? cc9Container,
    Color? onCc9Container,
    Color? sourceCc10,
    Color? cc10,
    Color? onCc10,
    Color? cc10Container,
    Color? onCc10Container,
  }) {
    return CustomColors(
      sourceCc1: sourceCc1 ?? this.sourceCc1,
      cc1: cc1 ?? this.cc1,
      onCc1: onCc1 ?? this.onCc1,
      cc1Container: cc1Container ?? this.cc1Container,
      onCc1Container: onCc1Container ?? this.onCc1Container,
      sourceCc2: sourceCc2 ?? this.sourceCc2,
      cc2: cc2 ?? this.cc2,
      onCc2: onCc2 ?? this.onCc2,
      cc2Container: cc2Container ?? this.cc2Container,
      onCc2Container: onCc2Container ?? this.onCc2Container,
      sourceCc3: sourceCc3 ?? this.sourceCc3,
      cc3: cc3 ?? this.cc3,
      onCc3: onCc3 ?? this.onCc3,
      cc3Container: cc3Container ?? this.cc3Container,
      onCc3Container: onCc3Container ?? this.onCc3Container,
      sourceCc4: sourceCc4 ?? this.sourceCc4,
      cc4: cc4 ?? this.cc4,
      onCc4: onCc4 ?? this.onCc4,
      cc4Container: cc4Container ?? this.cc4Container,
      onCc4Container: onCc4Container ?? this.onCc4Container,
      sourceCc5: sourceCc5 ?? this.sourceCc5,
      cc5: cc5 ?? this.cc5,
      onCc5: onCc5 ?? this.onCc5,
      cc5Container: cc5Container ?? this.cc5Container,
      onCc5Container: onCc5Container ?? this.onCc5Container,
      sourceCc6: sourceCc6 ?? this.sourceCc6,
      cc6: cc6 ?? this.cc6,
      onCc6: onCc6 ?? this.onCc6,
      cc6Container: cc6Container ?? this.cc6Container,
      onCc6Container: onCc6Container ?? this.onCc6Container,
      sourceCc7: sourceCc7 ?? this.sourceCc7,
      cc7: cc7 ?? this.cc7,
      onCc7: onCc7 ?? this.onCc7,
      cc7Container: cc7Container ?? this.cc7Container,
      onCc7Container: onCc7Container ?? this.onCc7Container,
      sourceCc8: sourceCc8 ?? this.sourceCc8,
      cc8: cc8 ?? this.cc8,
      onCc8: onCc8 ?? this.onCc8,
      cc8Container: cc8Container ?? this.cc8Container,
      onCc8Container: onCc8Container ?? this.onCc8Container,
      sourceCc9: sourceCc9 ?? this.sourceCc9,
      cc9: cc9 ?? this.cc9,
      onCc9: onCc9 ?? this.onCc9,
      cc9Container: cc9Container ?? this.cc9Container,
      onCc9Container: onCc9Container ?? this.onCc9Container,
      sourceCc10: sourceCc10 ?? this.sourceCc10,
      cc10: cc10 ?? this.cc10,
      onCc10: onCc10 ?? this.onCc10,
      cc10Container: cc10Container ?? this.cc10Container,
      onCc10Container: onCc10Container ?? this.onCc10Container,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      sourceCc1: Color.lerp(sourceCc1, other.sourceCc1, t),
      cc1: Color.lerp(cc1, other.cc1, t),
      onCc1: Color.lerp(onCc1, other.onCc1, t),
      cc1Container: Color.lerp(cc1Container, other.cc1Container, t),
      onCc1Container: Color.lerp(onCc1Container, other.onCc1Container, t),
      sourceCc2: Color.lerp(sourceCc2, other.sourceCc2, t),
      cc2: Color.lerp(cc2, other.cc2, t),
      onCc2: Color.lerp(onCc2, other.onCc2, t),
      cc2Container: Color.lerp(cc2Container, other.cc2Container, t),
      onCc2Container: Color.lerp(onCc2Container, other.onCc2Container, t),
      sourceCc3: Color.lerp(sourceCc3, other.sourceCc3, t),
      cc3: Color.lerp(cc3, other.cc3, t),
      onCc3: Color.lerp(onCc3, other.onCc3, t),
      cc3Container: Color.lerp(cc3Container, other.cc3Container, t),
      onCc3Container: Color.lerp(onCc3Container, other.onCc3Container, t),
      sourceCc4: Color.lerp(sourceCc4, other.sourceCc4, t),
      cc4: Color.lerp(cc4, other.cc4, t),
      onCc4: Color.lerp(onCc4, other.onCc4, t),
      cc4Container: Color.lerp(cc4Container, other.cc4Container, t),
      onCc4Container: Color.lerp(onCc4Container, other.onCc4Container, t),
      sourceCc5: Color.lerp(sourceCc5, other.sourceCc5, t),
      cc5: Color.lerp(cc5, other.cc5, t),
      onCc5: Color.lerp(onCc5, other.onCc5, t),
      cc5Container: Color.lerp(cc5Container, other.cc5Container, t),
      onCc5Container: Color.lerp(onCc5Container, other.onCc5Container, t),
      sourceCc6: Color.lerp(sourceCc6, other.sourceCc6, t),
      cc6: Color.lerp(cc6, other.cc6, t),
      onCc6: Color.lerp(onCc6, other.onCc6, t),
      cc6Container: Color.lerp(cc6Container, other.cc6Container, t),
      onCc6Container: Color.lerp(onCc6Container, other.onCc6Container, t),
      sourceCc7: Color.lerp(sourceCc7, other.sourceCc7, t),
      cc7: Color.lerp(cc7, other.cc7, t),
      onCc7: Color.lerp(onCc7, other.onCc7, t),
      cc7Container: Color.lerp(cc7Container, other.cc7Container, t),
      onCc7Container: Color.lerp(onCc7Container, other.onCc7Container, t),
      sourceCc8: Color.lerp(sourceCc8, other.sourceCc8, t),
      cc8: Color.lerp(cc8, other.cc8, t),
      onCc8: Color.lerp(onCc8, other.onCc8, t),
      cc8Container: Color.lerp(cc8Container, other.cc8Container, t),
      onCc8Container: Color.lerp(onCc8Container, other.onCc8Container, t),
      sourceCc9: Color.lerp(sourceCc9, other.sourceCc9, t),
      cc9: Color.lerp(cc9, other.cc9, t),
      onCc9: Color.lerp(onCc9, other.onCc9, t),
      cc9Container: Color.lerp(cc9Container, other.cc9Container, t),
      onCc9Container: Color.lerp(onCc9Container, other.onCc9Container, t),
      sourceCc10: Color.lerp(sourceCc10, other.sourceCc10, t),
      cc10: Color.lerp(cc10, other.cc10, t),
      onCc10: Color.lerp(onCc10, other.onCc10, t),
      cc10Container: Color.lerp(cc10Container, other.cc10Container, t),
      onCc10Container: Color.lerp(onCc10Container, other.onCc10Container, t),
    );
  }

  /// Returns an instance of [CustomColors] in which the following custom
  /// colors are harmonized with [dynamic]'s [ColorScheme.primary].
  ///
  /// See also:
  ///   * <https://m3.material.io/styles/color/the-color-system/custom-colors#harmonization>
  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith();
  }
}
