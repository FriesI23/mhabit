// Copyright 2025 Fries_I23
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

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

import '../annotation/proxy_annotation.dart';

class ProxyGenerator extends GeneratorForAnnotation<Proxy> {
  static String getMethodSignature(MethodElement method) {
    final name = method.name;
    final returnType = method.returnType.getDisplayString();

    final requiredPostionParams = method.parameters
        .where((param) => param.isRequiredPositional)
        .map((param) => '${param.type.getDisplayString()} ${param.name}')
        .toList();

    final optionalPostionParams = method.parameters
        .where((param) => param.isOptionalPositional)
        .map((param) => '${param.type.getDisplayString()} ${param.name}')
        .toList();

    final namedParams = method.parameters
        .where((param) => param.isNamed)
        .map((param) => '${param.isRequired ? "required " : ""}'
            '${param.type.getDisplayString()} ${param.name}'
            '${param.hasDefaultValue ? " = ${param.defaultValueCode}" : ""}')
        .toList();

    final requiredPostionStr = requiredPostionParams.isNotEmpty
        ? requiredPostionParams.join(', ')
        : '';
    final optionalPostionStr = optionalPostionParams.isNotEmpty
        ? "[${optionalPostionParams.join(', ')}]"
        : '';
    final namedStr =
        namedParams.isNotEmpty ? '{${namedParams.join(', ')}}' : '';

    final parameters = StringBuffer()
      ..write([requiredPostionStr, optionalPostionStr, namedStr]
          .where((e) => e.isNotEmpty)
          .join(', '));
    return '$returnType $name(${parameters.toString()})';
  }

  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    final targetClass = annotation.read('targetClass').typeValue;

    if (targetClass is! InterfaceType) {
      throw Exception('The target class should be a valid class.');
    }

    final baseClassName = targetClass.getDisplayString();

    final buffer = StringBuffer();
    buffer
        .writeln('class _\$${baseClassName}Proxy implements $baseClassName {');
    buffer.writeln('  final $baseClassName _base;');
    buffer.writeln('');
    buffer.writeln('  _\$${baseClassName}Proxy(this._base);');
    buffer.writeln('');

    void tryToGenDeprecatedFlag(Element element, {int intent = 0}) {
      final deprecatedFlag = element.metadata
          .firstWhereOrNull((annotation) => annotation.isDeprecated);
      final data = deprecatedFlag
          ?.computeConstantValue()
          ?.getField('message')
          ?.toStringValue()
          ?.trim();
      if (deprecatedFlag != null) {
        buffer.writeln(
            "${' ' * intent}@Deprecated(${data != null ? '"$data"' : ''})");
      }
    }

    for (var method in targetClass.element.methods) {
      if (method.isStatic) continue;

      String generateMethodCall() {
        final methodName = method.name;

        final positionalParams = <String>[];
        final namedParams = <String>[];
        for (var param in method.parameters) {
          final paramName = param.name;
          if (param.isNamed) {
            namedParams.add('$paramName: $paramName');
          } else {
            positionalParams.add(paramName);
          }
        }

        return '_base.$methodName(${[
          ...positionalParams,
          ...namedParams
        ].join(', ')})';
      }

      buffer.writeln('  @override');
      tryToGenDeprecatedFlag(method, intent: 2);
      buffer.writeln(
          '  ${getMethodSignature(method)} => ${generateMethodCall()};');
      buffer.writeln('');
    }

    final skipBuildFields = <String>{};
    for (var accessor in targetClass.element.accessors) {
      if (accessor.isStatic) continue;
      if (accessor.isGetter) {
        buffer.writeln('  @override');
        tryToGenDeprecatedFlag(accessor, intent: 2);
        buffer.writeln('  '
            '${accessor.returnType.getDisplayString()} '
            'get ${accessor.name} '
            '=> _base.${accessor.name};');
        buffer.writeln('');
        skipBuildFields.add(accessor.name);
      }
      if (accessor.isSetter) {
        buffer.writeln('  @override');
        tryToGenDeprecatedFlag(accessor, intent: 2);
        buffer.writeln('  '
            'set ${accessor.name.replaceFirst('=', '')}'
            '(${accessor.parameters.first.type.getDisplayString()} value) '
            '=> _base.${accessor.name} = value;');
        buffer.writeln('');
        skipBuildFields.add(accessor.name);
      }
    }

    for (var field in targetClass.element.fields) {
      if (field.isStatic || skipBuildFields.contains(field.name)) continue;
      buffer.writeln('  @override');
      tryToGenDeprecatedFlag(field, intent: 2);
      buffer.writeln('  '
          '${field.type.getDisplayString()} '
          'get ${field.name} '
          '=> _base.${field.name};');
      buffer.writeln('');
      if (!field.isFinal) {
        buffer.writeln('  @override');
        tryToGenDeprecatedFlag(field, intent: 2);
        buffer.writeln('  '
            'set ${field.name}'
            '(${field.type.getDisplayString()} value) '
            '=> _base.${field.name} = value;');
        buffer.writeln('');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }
}

/// Builder function to return a PartBuilder
Builder proxyGenerator(BuilderOptions options) {
  return SharedPartBuilder([ProxyGenerator()], 'proxy');
}
