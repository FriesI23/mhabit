// ignore_for_file: implementation_imports

import 'dart:io';
import 'dart:math' as math;

import 'package:args/args.dart';
import 'package:dart_style/dart_style.dart';
import 'package:icon_font_generator/icon_font_generator.dart';
import 'package:icon_font_generator/src/otf/table/name.dart';
import 'package:icon_font_generator/src/utils/misc.dart';
import 'package:path/path.dart' as p;

final _formatter = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
  pageWidth: 80,
);

final _fallbackBuildDate = DateTime.utc(2024, 1, 1);

const _generatedCopyrightPrefix = '// Copyright \u00A9 ';
const _generatedCopyrightSuffix =
    ' icon_font_generator (https://pub.dev/packages/icon_font_generator).';
const _svgPathCommandLetters = 'MmZzLlHhVvCcSsQqTtAa';

final _svgPathDataPattern = RegExp(
  r'''<path\b[^>]*\bd\s*=\s*(["'])(.*?)\1''',
  caseSensitive: false,
  dotAll: true,
);

final _argParser = ArgParser()
  ..addOption(
    'output-class-file',
    help: 'Path for the generated Dart icon class.',
  )
  ..addOption('class-name', help: 'Generated Dart icon class name.')
  ..addOption('font-name', help: 'Generated icon font family name.')
  ..addFlag(
    'format',
    negatable: false,
    help: 'Format the generated Dart class output.',
  )
  ..addFlag(
    'check-only',
    negatable: false,
    help: 'Validate SVGs and report problems without writing outputs.',
  )
  ..addOption(
    'build-date-epoch',
    help: 'Override the deterministic build timestamp in Unix seconds.',
  )
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show this help message.',
  );

void main(List<String> arguments) {
  try {
    final command = _parseCommand(arguments);
    final buildDate = _resolveBuildDate(command.buildDateEpochSeconds);
    final previousMockedDate = MockableDateTime.mockedDate;
    MockableDateTime.mockedDate = buildDate;

    try {
      _generateIconFont(command, buildDate);
    } finally {
      MockableDateTime.mockedDate = previousMockedDate;
    }
  } on _CliFailure catch (error) {
    stderr.writeln(error.message);
    exit(error.exitCode);
  } on ArgumentError catch (error) {
    stderr.writeln(error.message);
    exit(64);
  }
}

_IconFontCommand _parseCommand(List<String> arguments) {
  late final ArgResults argResults;
  try {
    argResults = _argParser.parse(arguments);
  } on ArgParserException catch (error) {
    throw ArgumentError('${error.message}\n\n$_usage');
  }

  if (argResults['help'] as bool) {
    stdout.writeln(_usage);
    exit(0);
  }

  final positional = argResults.rest;
  final outputClassFile = argResults['output-class-file'] as String?;
  final className = argResults['class-name'] as String?;
  final fontName = argResults['font-name'] as String?;
  final formatOutput = argResults['format'] as bool;
  final checkOnly = argResults['check-only'] as bool;
  final buildDateEpochSeconds = _parseBuildDateEpoch(
    argResults['build-date-epoch'] as String?,
  );

  if (positional.length != 2 ||
      outputClassFile == null ||
      className == null ||
      fontName == null) {
    throw ArgumentError('Missing required arguments.\n\n$_usage');
  }

  return _IconFontCommand(
    inputDir: positional[0],
    outputFontPath: positional[1],
    outputClassPath: outputClassFile,
    className: className,
    fontName: fontName,
    formatOutput: formatOutput,
    checkOnly: checkOnly,
    buildDateEpochSeconds: buildDateEpochSeconds,
  );
}

int? _parseBuildDateEpoch(String? rawValue) {
  if (rawValue == null || rawValue.isEmpty) {
    return null;
  }

  final parsedValue = int.tryParse(rawValue);
  if (parsedValue != null) {
    return parsedValue;
  }

  throw ArgumentError.value(
    rawValue,
    'build-date-epoch',
    'must be a Unix timestamp in seconds',
  );
}

DateTime _resolveBuildDate(int? buildDateEpochSeconds) {
  if (buildDateEpochSeconds != null) {
    return DateTime.fromMillisecondsSinceEpoch(
      buildDateEpochSeconds * 1000,
      isUtc: true,
    );
  }

  final sourceDateEpoch = Platform.environment['SOURCE_DATE_EPOCH'];
  if (sourceDateEpoch == null || sourceDateEpoch.isEmpty) {
    return _fallbackBuildDate;
  }

  final parsedSeconds = int.tryParse(sourceDateEpoch);
  if (parsedSeconds == null) {
    throw ArgumentError.value(
      sourceDateEpoch,
      'SOURCE_DATE_EPOCH',
      'must be a Unix timestamp in seconds',
    );
  }

  return DateTime.fromMillisecondsSinceEpoch(parsedSeconds * 1000, isUtc: true);
}

void _generateIconFont(_IconFontCommand command, DateTime buildDate) {
  final svgFiles =
      Directory(command.inputDir)
          .listSync()
          .whereType<File>()
          .where((file) => p.extension(file.path).toLowerCase() == '.svg')
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  if (svgFiles.isEmpty) {
    throw _CliFailure('No SVG icons found in ${command.inputDir}.');
  }

  final normalizedInputDir = p.normalize(command.inputDir);
  if (command.checkOnly) {
    stdout.writeln(
      'Checking ${command.fontName} in $normalizedInputDir '
      '(${svgFiles.length} SVG file(s))',
    );
  } else {
    stdout.writeln(
      'Generating ${command.fontName} from $normalizedInputDir '
      '(${svgFiles.length} SVG file(s))',
    );
  }

  final svgMap = <String, String>{};
  final validationIssues = <_SvgPathValidationIssue>[];

  for (final file in svgFiles) {
    final svgContent = file.readAsStringSync();
    svgMap[p.basenameWithoutExtension(file.path)] = svgContent;
    validationIssues.addAll(
      _findImplicitSubpathClosureIssues(
        filePath: file.path,
        svgContent: svgContent,
      ),
    );
  }

  if (validationIssues.isNotEmpty) {
    throw _CliFailure(_formatSvgValidationError(validationIssues));
  }

  if (command.checkOnly) {
    stdout.writeln(
      'Checked ${svgFiles.length} SVG file(s) in $normalizedInputDir: no '
      'implicit subpath-closure issues found.',
    );
    return;
  }

  final result = svgToOtf(
    svgMap: svgMap,
    fontName: command.fontName,
    ignoreShapes: true,
    normalize: true,
  );

  Directory(p.dirname(command.outputFontPath)).createSync(recursive: true);
  _stabilizeFontMetadata(result.font, buildDate);
  writeToFile(command.outputFontPath, result.font);

  final generatedClass = generateFlutterClass(
    glyphList: result.glyphList,
    className: command.className,
    familyName: command.fontName,
    fontFileName: p.basename(command.outputFontPath),
  );

  final formattedClass = command.formatOutput
      ? _formatter.format(generatedClass)
      : generatedClass;
  final stabilizedClass = _stabilizeGeneratedClass(formattedClass, buildDate);

  final outputFile = File(command.outputClassPath);
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(stabilizedClass);

  stdout.writeln(
    'Generated ${result.glyphList.length} glyph(s) for ${command.fontName}: '
    '${p.normalize(command.outputFontPath)}, '
    '${p.normalize(command.outputClassPath)}',
  );
}

List<_SvgPathValidationIssue> _findImplicitSubpathClosureIssues({
  required String filePath,
  required String svgContent,
}) {
  final issues = <_SvgPathValidationIssue>[];

  var pathIndex = 0;
  for (final match in _svgPathDataPattern.allMatches(svgContent)) {
    final pathData = match.group(2);
    if (pathData == null || pathData.isEmpty) {
      pathIndex++;
      continue;
    }

    for (final commandOffset in _findImplicitSubpathClosureOffsets(pathData)) {
      issues.add(
        _SvgPathValidationIssue(
          filePath: filePath,
          pathIndex: pathIndex,
          commandOffset: commandOffset,
          pathData: pathData,
        ),
      );
    }

    pathIndex++;
  }

  return issues;
}

List<int> _findImplicitSubpathClosureOffsets(String pathData) {
  final offsets = <int>[];
  var hasOpenSubpath = false;

  for (var index = 0; index < pathData.length; index++) {
    final character = pathData[index];
    if (!_svgPathCommandLetters.contains(character)) continue;

    switch (character) {
      case 'M':
      case 'm':
        if (hasOpenSubpath) {
          offsets.add(index);
        }
        hasOpenSubpath = true;
        break;
      case 'Z':
      case 'z':
        hasOpenSubpath = false;
        break;
    }
  }

  return offsets;
}

String _formatSvgValidationError(List<_SvgPathValidationIssue> issues) {
  final buffer = StringBuffer()
    ..writeln(
      'SVG validation failed: found <path> data that starts a new subpath '
      'before explicitly closing the previous contour with Z.',
    )
    ..writeln(
      'icon_font_generator can merge these contours into the wrong glyph. '
      'Split the path or add Z before the next M.',
    );

  for (final issue in issues) {
    buffer.writeln(
      '- ${p.normalize(issue.filePath)} path#${issue.pathIndex + 1}: '
      '${issue.contextSnippet}',
    );
  }

  return buffer.toString().trimRight();
}

void _stabilizeFontMetadata(OpenTypeFont font, DateTime buildDate) {
  final namingTable = font.name;
  if (namingTable is! NamingTableFormat0) return;

  for (var index = 0; index < namingTable.stringList.length; index++) {
    final value = namingTable.stringList[index];
    if (!value.startsWith('Copyright icon_font_generator ')) {
      continue;
    }
    namingTable.stringList[index] =
        'Copyright icon_font_generator ${buildDate.year}';
  }
}

String _stabilizeGeneratedClass(String content, DateTime buildDate) {
  return content.replaceAllMapped(
    RegExp(r'^// Copyright .*$', multiLine: true),
    (_) =>
        '$_generatedCopyrightPrefix${buildDate.year}$_generatedCopyrightSuffix',
  );
}

class _IconFontCommand {
  const _IconFontCommand({
    required this.inputDir,
    required this.outputFontPath,
    required this.outputClassPath,
    required this.className,
    required this.fontName,
    required this.formatOutput,
    required this.checkOnly,
    required this.buildDateEpochSeconds,
  });

  final String inputDir;
  final String outputFontPath;
  final String outputClassPath;
  final String className;
  final String fontName;
  final bool formatOutput;
  final bool checkOnly;
  final int? buildDateEpochSeconds;
}

class _CliFailure implements Exception {
  const _CliFailure(this.message);

  final String message;

  int get exitCode => 2;
}

class _SvgPathValidationIssue {
  const _SvgPathValidationIssue({
    required this.filePath,
    required this.pathIndex,
    required this.commandOffset,
    required this.pathData,
  });

  final String filePath;
  final int pathIndex;
  final int commandOffset;
  final String pathData;

  String get contextSnippet {
    final start = math.max(0, commandOffset - 24);
    final end = math.min(pathData.length, commandOffset + 24);
    final prefix = start == 0 ? '' : '...';
    final suffix = end == pathData.length ? '' : '...';
    final snippet = pathData
        .substring(start, end)
        .replaceAll(RegExp(r'\s+'), ' ');
    return '$prefix$snippet$suffix';
  }
}

String get _usage => [
  'Usage:',
  '  dart run bin/gen_icons.dart <input-dir> <output-font-path>',
  '    --output-class-file=<path> --class-name=<name> --font-name=<name> [options]',
  '',
  'Options:',
  _argParser.usage,
  '',
  'Environment:',
  '  SOURCE_DATE_EPOCH           Default deterministic build timestamp in seconds.',
].join('\n');
