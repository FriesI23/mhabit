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
import 'package:mhabit_proxy_annotation/proxy_annotation.dart';
import 'package:source_gen/source_gen.dart';

class ProxyGenerator extends GeneratorForAnnotation<Proxy> {
  static String getMethodSignature(MethodElement method) {
    final name = method.name;
    if (name == null) {
      throw InvalidGenerationSourceError(
        'Target method must have a name.',
        element: method,
      );
    }

    final returnType = method.returnType.getDisplayString();

    final requiredPostionParams = method.formalParameters
        .where((param) => param.isRequiredPositional)
        .map((param) => '${param.type.getDisplayString()} ${param.name}')
        .toList();

    final optionalPostionParams = method.formalParameters
        .where((param) => param.isOptionalPositional)
        .map(
          (param) =>
              '${param.type.getDisplayString()} ${param.name}'
              '${param.hasDefaultValue ? " = ${param.defaultValueCode}" : ""}',
        )
        .toList();

    final namedParams = method.formalParameters
        .where((param) => param.isNamed)
        .map(
          (param) =>
              '${param.isRequired ? "required " : ""}'
              '${param.type.getDisplayString()} ${param.name}'
              '${param.hasDefaultValue ? " = ${param.defaultValueCode}" : ""}',
        )
        .toList();

    final requiredPostionStr = requiredPostionParams.isNotEmpty
        ? requiredPostionParams.join(', ')
        : '';
    final optionalPostionStr = optionalPostionParams.isNotEmpty
        ? "[${optionalPostionParams.join(', ')}]"
        : '';
    final namedStr = namedParams.isNotEmpty
        ? '{${namedParams.join(', ')}}'
        : '';
    final parameterParts = <String>[
      requiredPostionStr,
      optionalPostionStr,
      namedStr,
    ]..removeWhere((part) => part.isEmpty);

    final parameters = StringBuffer()..write(parameterParts.join(', '));
    return '$returnType $name(${parameters.toString()})';
  }

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final targetClass = annotation.read('targetClass').typeValue;
    final useAnnotatedName = annotation.read('useAnnotatedName').boolValue;

    if (targetClass is! InterfaceType) {
      throw Exception('The target class should be a valid class.');
    }

    final targetClassName = targetClass.getDisplayString();
    final baseClassName = useAnnotatedName
        ? (element.name ?? targetClassName)
        : targetClassName;

    final buffer = StringBuffer();
    buffer.writeln(
      'class _\$${baseClassName}Proxy implements $targetClassName {',
    );
    buffer.writeln('  final $targetClassName _base;');
    buffer.writeln('');
    buffer.writeln('  _\$${baseClassName}Proxy(this._base);');
    buffer.writeln('');

    void tryToGenDeprecatedFlag(Element element, {int intent = 0}) {
      final metadata = element.metadata;
      if (!metadata.hasDeprecated) return;
      final deprecatedFlag = metadata.annotations.firstWhereOrNull(
        (annotation) => annotation.isDeprecated,
      );
      final data = deprecatedFlag
          ?.computeConstantValue()
          ?.getField('message')
          ?.toStringValue()
          ?.trim();
      if (deprecatedFlag != null) {
        buffer.writeln(
          "${' ' * intent}@Deprecated(${data != null ? '"$data"' : ''})",
        );
      }
    }

    final generatedMethods = <String>{};
    for (final method in [
      ...targetClass.element.methods,
      ...targetClass.allSupertypes.expand((type) => type.methods),
    ]) {
      final methodName = method.name;
      if (!method.isPublic ||
          method.isStatic ||
          method.isOperator ||
          methodName == null ||
          generatedMethods.contains(methodName)) {
        continue;
      }

      generatedMethods.add(methodName);

      String generateMethodCall() {
        final positionalParams = <String>[];
        final namedParams = <String>[];
        for (final param in method.formalParameters) {
          final paramName = param.name;
          if (paramName == null) continue;

          if (param.isNamed) {
            namedParams.add('$paramName: $paramName');
          } else {
            positionalParams.add(paramName);
          }
        }

        return '_base.$methodName(${[...positionalParams, ...namedParams].join(', ')})';
      }

      buffer.writeln('  @override');
      tryToGenDeprecatedFlag(method, intent: 2);
      buffer.writeln(
        '  ${getMethodSignature(method)} => ${generateMethodCall()};',
      );
      buffer.writeln('');
    }

    final skipBuildFields = <String>{};
    for (final getter in targetClass.element.getters) {
      if (getter.isStatic) continue;
      final getterName = getter.name;
      if (getterName == null) continue;
      buffer.writeln('  @override');
      tryToGenDeprecatedFlag(getter, intent: 2);
      buffer.writeln(
        '  '
        '${getter.returnType.getDisplayString()} '
        'get $getterName '
        '=> _base.$getterName;',
      );
      buffer.writeln('');
      skipBuildFields.add(getterName);
    }

    for (final setter in targetClass.element.setters) {
      if (setter.isStatic) continue;
      final setterNameWithEquals = setter.name;
      if (setterNameWithEquals == null) continue;
      final setterName = setterNameWithEquals.replaceFirst('=', '');
      buffer.writeln('  @override');
      tryToGenDeprecatedFlag(setter, intent: 2);
      buffer.writeln(
        '  '
        'set $setterName'
        '(${setter.formalParameters.first.type.getDisplayString()} value) '
        '=> _base.$setterName = value;',
      );
      buffer.writeln('');
      skipBuildFields.add(setterName);
    }

    for (final field in targetClass.element.fields) {
      final fieldName = field.name;
      if (field.isStatic ||
          fieldName == null ||
          skipBuildFields.contains(fieldName)) {
        continue;
      }

      buffer.writeln('  @override');
      tryToGenDeprecatedFlag(field, intent: 2);
      buffer.writeln(
        '  '
        '${field.type.getDisplayString()} '
        'get $fieldName '
        '=> _base.$fieldName;',
      );
      buffer.writeln('');
      if (!field.isFinal) {
        buffer.writeln('  @override');
        tryToGenDeprecatedFlag(field, intent: 2);
        buffer.writeln(
          '  '
          'set $fieldName'
          '(${field.type.getDisplayString()} value) '
          '=> _base.$fieldName = value;',
        );
        buffer.writeln('');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }
}

Builder proxyGenerator(BuilderOptions options) {
  return SharedPartBuilder([ProxyGenerator()], 'proxy');
}
