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
  final headingIdx = _findVersionHeading(nodes, version);
  if (headingIdx == null) return null;
  final sectionNodes = _collectSectionNodes(nodes, headingIdx + 1);
  return _renderNodesToMarkdown(sectionNodes);
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

/// Like [extractVersionSection], but if the exact [version] is not found,
/// strips flavor suffixes (`-dev`, `-alpha`, etc.) and retries.
///
/// This is the pre-loaded-content variant of [loadChangelogForVersion], for
/// callers that already hold the raw changelog text.
String? extractVersionSectionWithFallback(String content, String version) {
  final section = extractVersionSection(content, version);
  if (section != null) return section;
  final baseVersion = version.replaceFirst(RegExp(r'-\w+\+'), '+');
  if (baseVersion == version) return null;
  return extractVersionSection(content, baseVersion);
}

/// Strips the preamble (title, links) from raw CHANGELOG.md [content],
/// returning only the version heading lines and their body content.
///
/// Finds the first `## ` (h2) heading and returns everything from that
/// point onward. If no h2 is found, returns [content] unchanged.
String stripChangelogPreamble(String content) {
  final match = RegExp(r'^## ', multiLine: true).firstMatch(content);
  return match != null ? content.substring(match.start) : content;
}

int? _findVersionHeading(List<md.Node> nodes, String version) {
  for (final (index, node) in nodes.indexed) {
    if (node case md.Element(
      tag: 'h2',
    ) when node.textContent.trim() == version) {
      return index;
    }
  }
  return null;
}

List<md.Node> _collectSectionNodes(List<md.Node> nodes, int start) {
  final result = <md.Node>[];
  for (final node in nodes.skip(start)) {
    if (node case md.Element(tag: 'h2')) break;
    result.add(node);
  }
  return result;
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
