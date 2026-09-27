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

/// A structured iOS, iPadOS, or macOS release number.
///
/// Missing minor or patch components are normalized to zero.
final class AppleSystemVersion implements Comparable<AppleSystemVersion> {
  const AppleSystemVersion(this.major, [this.minor = 0, this.patch = 0])
    : assert(major >= 0),
      assert(minor >= 0),
      assert(patch >= 0);

  /// The major release component.
  final int major;

  /// The minor release component.
  final int minor;

  /// The patch release component.
  final int patch;

  /// Parses one to three dot-separated non-negative integer components.
  ///
  /// Returns null when [source] is empty or malformed.
  static AppleSystemVersion? tryParse(String source) {
    final components = source.trim().split('.');
    if (components.isEmpty || components.length > 3) return null;

    final values = <int>[];
    for (final component in components) {
      if (!RegExp(r'^\d+$').hasMatch(component)) return null;
      final value = int.tryParse(component);
      if (value == null) return null;
      values.add(value);
    }
    return AppleSystemVersion(
      values[0],
      values.length > 1 ? values[1] : 0,
      values.length > 2 ? values[2] : 0,
    );
  }

  /// Parses Dart's decorated Apple operating-system version string.
  ///
  /// macOS commonly reports values such as
  /// `Version 27.0.1 (Build 26A123)`. A plain dotted version is accepted too.
  static AppleSystemVersion? tryParseOperatingSystemVersion(String source) {
    final plain = tryParse(source);
    if (plain != null) return plain;

    final match = RegExp(
      r'\bVersion\s+(\d+)(?:\.(\d+))?(?:\.(\d+))?',
    ).firstMatch(source);
    if (match == null) return null;
    return AppleSystemVersion(
      int.parse(match.group(1)!),
      int.tryParse(match.group(2) ?? '') ?? 0,
      int.tryParse(match.group(3) ?? '') ?? 0,
    );
  }

  @override
  int compareTo(AppleSystemVersion other) {
    final majorComparison = major.compareTo(other.major);
    if (majorComparison != 0) return majorComparison;

    final minorComparison = minor.compareTo(other.minor);
    if (minorComparison != 0) return minorComparison;

    return patch.compareTo(other.patch);
  }

  bool operator <(AppleSystemVersion other) => compareTo(other) < 0;

  bool operator <=(AppleSystemVersion other) => compareTo(other) <= 0;

  bool operator >(AppleSystemVersion other) => compareTo(other) > 0;

  bool operator >=(AppleSystemVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is AppleSystemVersion &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
