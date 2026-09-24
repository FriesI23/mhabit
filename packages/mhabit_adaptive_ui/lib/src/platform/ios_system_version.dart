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

/// A structured iOS or iPadOS release number.
///
/// Missing minor or patch components are normalized to zero.
final class IosSystemVersion implements Comparable<IosSystemVersion> {
  const IosSystemVersion(this.major, [this.minor = 0, this.patch = 0])
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
  static IosSystemVersion? tryParse(String source) {
    final components = source.trim().split('.');
    if (components.isEmpty || components.length > 3) return null;

    final values = <int>[];
    for (final component in components) {
      if (!RegExp(r'^\d+$').hasMatch(component)) return null;
      final value = int.tryParse(component);
      if (value == null) return null;
      values.add(value);
    }
    return IosSystemVersion(
      values[0],
      values.length > 1 ? values[1] : 0,
      values.length > 2 ? values[2] : 0,
    );
  }

  @override
  int compareTo(IosSystemVersion other) {
    final majorComparison = major.compareTo(other.major);
    if (majorComparison != 0) return majorComparison;

    final minorComparison = minor.compareTo(other.minor);
    if (minorComparison != 0) return minorComparison;

    return patch.compareTo(other.patch);
  }

  bool operator <(IosSystemVersion other) => compareTo(other) < 0;

  bool operator <=(IosSystemVersion other) => compareTo(other) <= 0;

  bool operator >(IosSystemVersion other) => compareTo(other) > 0;

  bool operator >=(IosSystemVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is IosSystemVersion &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
