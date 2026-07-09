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

import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;

import '../../assets/assets.dart';
import '../../extensions/asset_bundle_extensions.dart';

/// A single version section parsed from a changelog.
///
/// [version] is the `## <version>` heading text (e.g. `"1.25.3+168"`).
/// [body] is the section body rendered back to markdown, or empty string
/// when the section has no body content.
final class ChangelogSection {
  final String version;
  final String body;

  const ChangelogSection({required this.version, required this.body});
}

/// Parses [content] into a list of [ChangelogSection]s, one per `## ` h2
/// heading.
///
/// Each section spans from its `## <version>` heading to the next `## `
/// heading (or EOF). The section body is rendered back to markdown via the
/// same `_renderNodesToMarkdown` pipeline used by [extractVersionSection].
///
/// [content] should be the raw CHANGELOG.md text. Callers that have already
/// stripped the preamble via [stripChangelogPreamble] can pass the result
/// directly.
List<ChangelogSection> parseChangelogSections(String content) {
  final nodes = md.Document().parse(content);
  final sections = <ChangelogSection>[];

  _forEachVersionSection(nodes, (version, bodyStart) {
    final bodyNodes = _collectSectionNodes(nodes, bodyStart);
    final body = _renderNodesToMarkdown(bodyNodes);
    sections.add(ChangelogSection(version: version, body: body));
    return true;
  });

  return sections;
}

/// Extracts the body markdown for [version] from raw [content].
///
/// [content] is the full text of a changelog file.
/// [version] is a `"<semver>+<buildNumber>"` string matching the
/// `pubspec.yaml` / changelog `+` convention.
///
/// Returns the section body (list items etc.) as markdown text without the
/// `## <version>` heading, or `null` when no matching heading is found.
String? extractVersionSection(String content, String version) {
  final nodes = md.Document().parse(content);
  String? section;

  _forEachVersionSection(nodes, (heading, bodyStart) {
    if (heading != version) return true;
    final bodyNodes = _collectSectionNodes(nodes, bodyStart);
    section = _renderNodesToMarkdown(bodyNodes);
    return false;
  });

  return section;
}

/// Loads a changelog asset from [path] and returns the body markdown for
/// [version].
///
/// [path] defaults to `'CHANGELOG.md'`. If an exact match for [version]
/// is not found, strips flavor suffixes (`-dev`, `-alpha`, etc.) and retries.
Future<String?> loadChangelogForVersion(
  String version, {
  String path = Assets.changelog,
}) async {
  final content = await rootBundle.loadChangelog(path);
  return extractVersionSectionWithFallback(content, version);
}

// Splits e.g. "1.25.4+169-pre" → (base: "1.25.4+169", suffix: "pre")
// or "1.25.4-dev+169" → (base: "1.25.4+169", suffix: "dev").
// Always produces a stable base of the form "<semver>+<buildNumber>".
({String base, String? suffix}) _splitVersion(String version) {
  final plusIdx = version.indexOf('+');
  if (plusIdx == -1) return (base: version, suffix: null);

  // Suffix after build number: "1.25.4+169-pre"
  final dashAfterPlus = version.indexOf('-', plusIdx);
  if (dashAfterPlus != -1) {
    return (
      base: version.substring(0, dashAfterPlus),
      suffix: version.substring(dashAfterPlus + 1),
    );
  }

  // Suffix between semver and build number: "1.25.4-dev+169"
  final dashBeforePlus = version.lastIndexOf('-', plusIdx);
  if (dashBeforePlus != -1) {
    return (
      base:
          '${version.substring(0, dashBeforePlus)}${version.substring(plusIdx)}',
      suffix: version.substring(dashBeforePlus + 1, plusIdx),
    );
  }

  return (base: version, suffix: null);
}

/// Finds the first h2 heading matching [predicate], collects its body
/// nodes, and renders them back to markdown.
///
/// Returns `null` when no h2 heading satisfies [predicate].
String? _findAndRenderFirstSection(
  String content,
  bool Function(String headingText) predicate,
) {
  final nodes = md.Document().parse(content);
  for (var i = 0; i < nodes.length; i++) {
    final node = nodes[i];
    if (node case md.Element(tag: 'h2')) {
      final text = node.textContent.trim();
      if (!predicate(text)) continue;
      final bodyNodes = _collectSectionNodes(nodes, i + 1);
      return _renderNodesToMarkdown(bodyNodes);
    }
  }
  return null;
}

/// Like [extractVersionSection], but with fallback: strips flavor suffix
/// from the code version, or matches CHANGELOG headings that share the same
/// base with a different `-suffix`.
///
/// Fallback levels (from most to least specific):
///   1. Exact match — [extractVersionSection]
///   2. Stripped suffix / beta heading — [_tryBetaHeading]
///   3. Semver-only — [_tryMatchBySemver] (ignores build number —
///      handles app-store-transformed versionCodes like F-Droid ABI prefix)
///   4. Latest section — only when [useLatestFallback] is `true`
///      (first h2 in content; for manual triggers like About page)
String? extractVersionSectionWithFallback(
  String content,
  String version, {
  bool useLatestFallback = false,
}) {
  // 1. Exact match.
  final section = extractVersionSection(content, version);
  if (section != null) return section;

  final (:base, :suffix) = _splitVersion(version);

  // 2. Stripped suffix / beta heading.
  final strippedResult = switch (suffix) {
    final _? =>
      extractVersionSection(content, base) ?? _tryBetaHeading(content, base),
    _ => _tryBetaHeading(content, base),
  };
  if (strippedResult != null) return strippedResult;

  // 3. Semver-only match (ignores build number).
  final semverResult = _tryMatchBySemver(content, base);
  if (semverResult != null) return semverResult;

  // 4. Ultimate fallback (manual triggers only).
  return useLatestFallback ? _tryLatestSection(content) : null;
}

/// Looks for a CHANGELOG h2 heading that starts with [base]-.
///
/// Handles the case where the code version is stable (e.g. 1.25.5+170)
/// but the CHANGELOG heading has a pre-release suffix (1.25.5+170-pre).
String? _tryBetaHeading(String content, String base) =>
    _findAndRenderFirstSection(content, (t) => t.startsWith('$base-'));

/// Matches any h2 heading whose semver part equals [version]'s semver,
/// ignoring the build number.
///
/// Handles cases where app stores transform the build number
/// (e.g. F-Droid ARM64 prefix: 170 → 2170).
String? _tryMatchBySemver(String content, String version) {
  final plusIdx = version.indexOf('+');
  if (plusIdx == -1) return null;
  final semver = version.substring(0, plusIdx);
  return _findAndRenderFirstSection(content, (t) => t.startsWith('$semver+'));
}

/// Returns the body of the first h2 section — the latest changelog entry.
///
/// Ultimate fallback when no other version-matching strategy succeeds.
String? _tryLatestSection(String content) =>
    _findAndRenderFirstSection(content, (_) => true);

/// Strips the preamble (title, links) from raw CHANGELOG.md [content],
/// returning only the version heading lines and their body content.
///
/// Finds the first `## ` (h2) heading and returns everything from that
/// point onward. If no h2 is found, returns [content] unchanged.
String stripChangelogPreamble(String content) {
  final match = RegExp(r'^## ', multiLine: true).firstMatch(content);
  return match != null ? content.substring(match.start) : content;
}

List<md.Node> _collectSectionNodes(List<md.Node> nodes, int start) {
  final result = <md.Node>[];
  for (final node in nodes.skip(start)) {
    if (node case md.Element(tag: 'h2')) break;
    result.add(node);
  }
  return result;
}

void _forEachVersionSection(
  List<md.Node> nodes,
  bool Function(String version, int bodyStart) visitor,
) {
  for (var i = 0; i < nodes.length; i++) {
    final node = nodes[i];
    if (node case md.Element(tag: 'h2')) {
      final keepWalking = visitor(node.textContent.trim(), i + 1);
      if (!keepWalking) return;
    }
  }
}

String _renderNodesToMarkdown(List<md.Node> nodes) {
  final out = StringBuffer();
  for (final node in nodes) {
    _renderNode(node, out);
  }
  return out.toString().trimRight();
}

void _renderNode(md.Node node, StringBuffer out) {
  switch (node) {
    case md.Text(:final text):
      out.write(text);
    case md.Element(:final tag, :final children):
      final c = children ?? [];
      switch (tag) {
        case 'p':
          for (final child in c) {
            _renderNode(child, out);
          }
          out.writeln();
          out.writeln();
        case 'ul':
          for (final child in c) {
            out.write('- ');
            _renderNode(child, out);
            out.writeln();
          }
        case 'li':
          for (final child in c) {
            _renderNode(child, out);
          }
        case 'em':
          out.write('*');
          for (final child in c) {
            _renderNode(child, out);
          }
          out.write('*');
        case 'strong':
          out.write('**');
          for (final child in c) {
            _renderNode(child, out);
          }
          out.write('**');
        case 'a':
          out.write('[');
          for (final child in c) {
            _renderNode(child, out);
          }
          out.write('](${node.attributes['href']})');
        case 'code':
          out.write('`');
          for (final child in c) {
            _renderNode(child, out);
          }
          out.write('`');
        case 'br':
          out.writeln();
        case _:
          for (final child in c) {
            _renderNode(child, out);
          }
      }
  }
}
