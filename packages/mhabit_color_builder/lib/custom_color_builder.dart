// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:math' as math;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart' as cb;
import 'package:dart_style/dart_style.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:mhabit_color_annotation/mhabit_color_annotation.dart';
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

const _configSectionKey = 'mhabit_color_builder';
const _defaultPrimaryMinChroma = 48.0;
const _defaultLightPrimaryTone = 56;
const _defaultDarkPrimaryTone = 80;

final _dartEmitter = cb.DartEmitter.scoped(useNullSafetySyntax: true);
final _dartFormatter = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
);

Builder customColorBuilder(BuilderOptions _) {
  return SharedPartBuilder([CustomColorGenerator()], 'custom_color_builder');
}

class CustomColorGenerator
    extends GeneratorForAnnotation<GenerateCustomColors> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final pubspecId = AssetId(buildStep.inputId.package, 'pubspec.yaml');
    if (!await buildStep.canRead(pubspecId)) {
      throw InvalidGenerationSourceError(
        'Expected ${pubspecId.path} to exist.',
        element: element,
      );
    }

    final configName = annotation.read('configName').stringValue;
    try {
      // The annotation only selects a named pubspec entry; all validation and
      // fallback behavior stays in the pure parser below so tests can cover it
      // without running build_runner.
      return generateCustomColorPartFromPubspec(
        await buildStep.readAsString(pubspecId),
        configName: configName,
        sourcePath: pubspecId.path,
      );
    } on FormatException catch (error) {
      throw InvalidGenerationSourceError(error.message, element: element);
    }
  }
}

String generateCustomColorPartFromPubspec(
  String pubspecContent, {
  required String configName,
  String sourcePath = 'pubspec.yaml',
}) {
  final config = _GeneratorConfig.fromPubspec(
    pubspecContent,
    sourcePath,
    configName,
  );
  return _buildOutput(config, sourcePath, configName);
}

class _GeneratorConfig {
  const _GeneratorConfig({
    required this.lightPrimaryMinChroma,
    required this.darkPrimaryMinChroma,
    required this.lightPrimaryTone,
    required this.darkPrimaryTone,
    required this.seeds,
  });

  final double lightPrimaryMinChroma;
  final double darkPrimaryMinChroma;
  final int lightPrimaryTone;
  final int darkPrimaryTone;
  final List<_ColorSeed> seeds;

  static _GeneratorConfig fromPubspec(
    String pubspecContent,
    String path,
    String configName,
  ) {
    final rawPubspec = loadYaml(pubspecContent);
    if (rawPubspec is! YamlMap) {
      throw FormatException('Expected a YAML object in $path.');
    }

    final rawConfigs = rawPubspec[_configSectionKey];
    if (rawConfigs is! YamlMap) {
      throw FormatException(
        'Expected a top-level "$_configSectionKey" section in $path.',
      );
    }

    if (!rawConfigs.containsKey(configName)) {
      throw FormatException(
        'Could not find $_configSectionKey["$configName"] in $path.',
      );
    }

    final rawConfig = rawConfigs[configName];
    if (rawConfig is! YamlMap) {
      throw FormatException(
        'Expected $_configSectionKey["$configName"] to be a YAML object in '
        '$path.',
      );
    }

    final colors = rawConfig['colors'];
    if (colors is! YamlMap) {
      throw FormatException(
        'Expected colors under $_configSectionKey["$configName"] in $path.',
      );
    }

    final primaryMinChroma = _readOptionalDouble(
      rawConfig,
      path,
      configName,
      'primary_min_chroma',
    );
    // Override chain: light/dark-specific value -> shared primary value ->
    // code default. Keeping the precedence inline here makes the generated
    // output behavior easy to compare against the pubspec shape.
    final lightPrimaryMinChroma =
        _readOptionalDouble(
          rawConfig,
          path,
          configName,
          'light_primary_min_chroma',
        ) ??
        primaryMinChroma ??
        _defaultPrimaryMinChroma;
    final darkPrimaryMinChroma =
        _readOptionalDouble(
          rawConfig,
          path,
          configName,
          'dark_primary_min_chroma',
        ) ??
        primaryMinChroma ??
        _defaultPrimaryMinChroma;

    final primaryTone = _readOptionalInt(
      rawConfig,
      path,
      configName,
      'primary_tone',
    );
    final lightPrimaryTone =
        _readOptionalInt(rawConfig, path, configName, 'light_primary_tone') ??
        primaryTone ??
        _defaultLightPrimaryTone;
    final darkPrimaryTone =
        _readOptionalInt(rawConfig, path, configName, 'dark_primary_tone') ??
        primaryTone ??
        _defaultDarkPrimaryTone;

    return _GeneratorConfig(
      lightPrimaryMinChroma: lightPrimaryMinChroma.toDouble(),
      darkPrimaryMinChroma: darkPrimaryMinChroma.toDouble(),
      lightPrimaryTone: lightPrimaryTone.toInt(),
      darkPrimaryTone: darkPrimaryTone.toInt(),
      seeds: [
        for (final entry in colors.entries)
          _ColorSeed.fromConfigEntry(
            name: entry.key,
            value: entry.value,
            path: path,
            configName: configName,
          ),
      ],
    );
  }

  static double? _readOptionalDouble(
    YamlMap rawConfig,
    String path,
    String configName,
    String key,
  ) {
    final value = rawConfig[key];
    if (value == null) return null;
    if (value is! num) {
      throw FormatException(
        'Expected $_configSectionKey["$configName"]["$key"] to be a number '
        'in $path.',
      );
    }
    return value.toDouble();
  }

  static int? _readOptionalInt(
    YamlMap rawConfig,
    String path,
    String configName,
    String key,
  ) {
    final value = rawConfig[key];
    if (value == null) return null;
    if (value is! num) {
      throw FormatException(
        'Expected $_configSectionKey["$configName"]["$key"] to be a number '
        'in $path.',
      );
    }
    return value.toInt();
  }
}

class _ColorSeed {
  const _ColorSeed({required this.name, required this.argb});

  final String name;
  final int argb;

  static _ColorSeed fromConfigEntry({
    required Object? name,
    required Object? value,
    required String path,
    required String configName,
  }) {
    if (name is! String) {
      throw FormatException(
        'Expected each custom color name under '
        '$_configSectionKey["$configName"]["colors"] to be a string '
        'in $path.',
      );
    }

    return _ColorSeed(name: name, argb: _parseArgb(value));
  }

  static int _parseArgb(Object? rawValue) {
    if (rawValue is int) return rawValue;
    if (rawValue is! String) {
      throw const FormatException(
        'Expected each custom color value to be a string or integer.',
      );
    }

    final normalizedValue =
        rawValue.startsWith('0x') || rawValue.startsWith('0X')
        ? rawValue.substring(2)
        : rawValue;
    return int.parse(normalizedValue, radix: 16);
  }
}

class _ColorRoles {
  const _ColorRoles({
    required this.source,
    required this.light,
    required this.dark,
  });

  final int source;
  final _SchemeRoles light;
  final _SchemeRoles dark;
}

class _SchemeRoles {
  const _SchemeRoles({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final int color;
  final int onColor;
  final int colorContainer;
  final int onColorContainer;
}

class _GeneratedColorDefinition {
  const _GeneratedColorDefinition({required this.seed, required this.roles});

  final _ColorSeed seed;
  final _ColorRoles roles;

  String get capitalizedName => _capitalize(seed.name);
  String get sourceFieldName => 'source$capitalizedName';
  String get colorFieldName => seed.name;
  String get onColorFieldName => 'on$capitalizedName';
  String get containerFieldName => '${seed.name}Container';
  String get onColorContainerFieldName => 'on${capitalizedName}Container';
}

String _buildOutput(
  _GeneratorConfig config,
  String sourcePath,
  String configName,
) {
  final generatedColors = [
    for (final seed in config.seeds)
      _GeneratedColorDefinition(seed: seed, roles: _buildRoles(seed, config)),
  ];
  // SharedPartBuilder and source_gen own the surrounding `part of` file shell;
  // this function only emits the generated declarations that get merged into
  // the final `.g.dart`.
  final library = cb.Library(
    (builder) => builder.body.addAll([
      for (final color in generatedColors) _buildSeedField(color),
      _buildSchemeField(
        name: 'lightCustomColors',
        generatedColors: generatedColors,
        schemeSelector: (roles) => roles.light,
      ),
      _buildSchemeField(
        name: 'darkCustomColors',
        generatedColors: generatedColors,
        schemeSelector: (roles) => roles.dark,
      ),
      _buildCustomColorsClass(generatedColors),
    ]),
  );

  const generatedHeader = '// ignore_for_file: type=lint';
  final sourceComment =
      '// Source: $sourcePath > $_configSectionKey["$configName"]';
  final body = '${library.accept(_dartEmitter)}';
  return _dartFormatter.format('$generatedHeader\n$sourceComment\n\n$body');
}

cb.Field _buildSeedField(_GeneratedColorDefinition color) {
  return cb.Field(
    (builder) => builder
      ..modifier = cb.FieldModifier.constant
      ..name = color.seed.name
      ..assignment = _colorExpression(color.seed.argb).code,
  );
}

cb.Field _buildSchemeField({
  required String name,
  required List<_GeneratedColorDefinition> generatedColors,
  required _SchemeRoles Function(_ColorRoles roles) schemeSelector,
}) {
  final namedArguments = <String, cb.Expression>{};
  for (final color in generatedColors) {
    final scheme = schemeSelector(color.roles);
    namedArguments[color.sourceFieldName] = _colorExpression(
      color.roles.source,
    );
    namedArguments[color.colorFieldName] = _colorExpression(scheme.color);
    namedArguments[color.onColorFieldName] = _colorExpression(scheme.onColor);
    namedArguments[color.containerFieldName] = _colorExpression(
      scheme.colorContainer,
    );
    namedArguments[color.onColorContainerFieldName] = _colorExpression(
      scheme.onColorContainer,
    );
  }

  return cb.Field(
    (builder) => builder
      ..name = name
      ..type = _customColorsType
      ..assignment = _customColorsType.constInstance([], namedArguments).code,
  );
}

cb.Class _buildCustomColorsClass(
  List<_GeneratedColorDefinition> generatedColors,
) {
  final fieldNames = [
    for (final color in generatedColors) ..._fieldNamesFor(color),
  ];

  return cb.Class(
    (builder) => builder
      ..annotations.add(cb.refer('immutable'))
      ..docs.addAll(const [
        '/// Defines a set of custom colors, each comprised of 4 complementary tones.',
        '///',
        '/// See also:',
        '///   * <https://m3.material.io/styles/color/the-color-system/custom-colors>',
      ])
      ..name = 'CustomColors'
      ..extend = _themeExtensionType(nullable: false)
      ..constructors.add(
        cb.Constructor(
          (builder) => builder
            ..constant = true
            ..optionalParameters.addAll([
              for (final fieldName in fieldNames)
                cb.Parameter(
                  (builder) => builder
                    ..name = fieldName
                    ..named = true
                    ..required = true
                    ..toThis = true,
                ),
            ]),
        ),
      )
      ..fields.addAll([
        for (final fieldName in fieldNames)
          cb.Field(
            (builder) => builder
              ..modifier = cb.FieldModifier.final$
              ..name = fieldName
              ..type = _nullableColorType,
          ),
      ])
      ..methods.addAll([
        _buildCopyWithMethod(fieldNames),
        _buildLerpMethod(fieldNames),
        _buildHarmonizedMethod(),
      ]),
  );
}

cb.Method _buildCopyWithMethod(List<String> fieldNames) {
  return cb.Method(
    (builder) => builder
      ..annotations.add(cb.refer('override'))
      ..returns = _customColorsType
      ..name = 'copyWith'
      ..lambda = false
      ..optionalParameters.addAll([
        for (final fieldName in fieldNames)
          cb.Parameter(
            (builder) => builder
              ..name = fieldName
              ..named = true
              ..type = _nullableColorType,
          ),
      ])
      ..body = _customColorsType
          .newInstance([], {
            for (final fieldName in fieldNames)
              fieldName: cb
                  .refer(fieldName)
                  .ifNullThen(cb.refer('this').property(fieldName)),
          })
          .returned
          .statement,
  );
}

cb.Method _buildLerpMethod(List<String> fieldNames) {
  return cb.Method(
    (builder) => builder
      ..annotations.add(cb.refer('override'))
      ..returns = _customColorsType
      ..name = 'lerp'
      ..lambda = false
      ..requiredParameters.addAll([
        cb.Parameter(
          (builder) => builder
            ..name = 'other'
            ..type = _themeExtensionType(nullable: true),
        ),
        cb.Parameter(
          (builder) => builder
            ..name = 't'
            ..type = cb.refer('double'),
        ),
      ])
      ..body = cb.Block.of([
        const cb.Code('if (other is! CustomColors) return this;'),
        _customColorsType
            .newInstance([], {
              for (final fieldName in fieldNames)
                fieldName: cb.refer('Color').property('lerp').call([
                  cb.refer(fieldName),
                  cb.refer('other').property(fieldName),
                  cb.refer('t'),
                ]),
            })
            .returned
            .statement,
      ]),
  );
}

cb.Method _buildHarmonizedMethod() {
  return cb.Method(
    (builder) => builder
      ..docs.addAll(const [
        '/// Returns an instance of [CustomColors] in which the following custom',
        "/// colors are harmonized with [colorScheme]'s [ColorScheme.primary].",
        '///',
        '/// See also:',
        '///   * <https://m3.material.io/styles/color/the-color-system/custom-colors#harmonization>',
      ])
      ..returns = _customColorsType
      ..name = 'harmonized'
      ..lambda = false
      ..requiredParameters.add(
        cb.Parameter(
          (builder) => builder
            ..name = 'colorScheme'
            ..type = cb.refer('ColorScheme'),
        ),
      )
      ..body = cb.refer('copyWith').call([]).returned.statement,
  );
}

Iterable<String> _fieldNamesFor(_GeneratedColorDefinition color) sync* {
  yield color.sourceFieldName;
  yield color.colorFieldName;
  yield color.onColorFieldName;
  yield color.containerFieldName;
  yield color.onColorContainerFieldName;
}

cb.TypeReference _themeExtensionType({required bool nullable}) {
  return cb.TypeReference(
    (builder) => builder
      ..symbol = 'ThemeExtension'
      ..isNullable = nullable
      ..types.add(_customColorsType),
  );
}

final _customColorsType = cb.refer('CustomColors').type;
final _nullableColorType = cb.TypeReference(
  (builder) => builder
    ..symbol = 'Color'
    ..isNullable = true,
);

cb.Expression _colorExpression(int argb) {
  return cb.refer('Color').constInstance([_hexLiteralExpression(argb)]);
}

cb.Expression _hexLiteralExpression(int argb) {
  final hexValue = argb.toRadixString(16).toUpperCase().padLeft(8, '0');
  return cb.CodeExpression(cb.Code('0x$hexValue'));
}

_ColorRoles _buildRoles(_ColorSeed seed, _GeneratorConfig config) {
  final source = Hct.fromInt(seed.argb);
  // Light and dark palettes are derived separately so per-mode overrides can
  // diverge without introducing extra branching in the role mapping below.
  final lightPrimaryPalette = TonalPalette.of(
    source.hue,
    math.max(config.lightPrimaryMinChroma, source.chroma).toDouble(),
  );
  final darkPrimaryPalette = TonalPalette.of(
    source.hue,
    math.max(config.darkPrimaryMinChroma, source.chroma).toDouble(),
  );

  return _ColorRoles(
    source: seed.argb,
    light: _SchemeRoles(
      color: lightPrimaryPalette.get(config.lightPrimaryTone),
      onColor: lightPrimaryPalette.get(100),
      colorContainer: lightPrimaryPalette.get(90),
      onColorContainer: lightPrimaryPalette.get(10),
    ),
    dark: _SchemeRoles(
      color: darkPrimaryPalette.get(config.darkPrimaryTone),
      onColor: darkPrimaryPalette.get(20),
      colorContainer: darkPrimaryPalette.get(30),
      onColorContainer: darkPrimaryPalette.get(90),
    ),
  );
}

String _capitalize(String value) {
  return value[0].toUpperCase() + value.substring(1);
}
