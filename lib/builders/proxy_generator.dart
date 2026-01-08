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

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations/proxy_annotation.dart';

class ProxyGenerator extends GeneratorForAnnotation<Proxy> {
  static String getMethodSignature(MethodElement2 method) {
    final name = method.name3;
    final returnType = method.returnType.getDisplayString();

    final requiredPostionParams = method.formalParameters
        .where((param) => param.isRequiredPositional)
        .map((param) => '${param.type.getDisplayString()} ${param.name3}')
        .toList();

    final optionalPostionParams = method.formalParameters
        .where((param) => param.isOptionalPositional)
        .map(
          (param) =>
              '${param.type.getDisplayString()} ${param.name3}'
              '${param.hasDefaultValue ? " = ${param.defaultValueCode}" : ""}',
        )
        .toList();

    final namedParams = method.formalParameters
        .where((param) => param.isNamed)
        .map(
          (param) =>
              '${param.isRequired ? "required " : ""}'
              '${param.type.getDisplayString()} ${param.name3}'
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

    final parameters = StringBuffer()
      ..write(
        [
          requiredPostionStr,
          optionalPostionStr,
          namedStr,
        ].where((e) => e.isNotEmpty).join(', '),
      );
    return '$returnType $name(${parameters.toString()})';
  }

  @override
  Future<String> generateForAnnotatedElement(
    Element2 element,
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
        ? element.name3
        : targetClass.getDisplayString();

    final buffer = StringBuffer();
    buffer.writeln(
      'class _\$${baseClassName}Proxy implements $targetClassName {',
    );
    buffer.writeln('  final $targetClassName _base;');
    buffer.writeln('');
    buffer.writeln('  _\$${baseClassName}Proxy(this._base);');
    buffer.writeln('');

    void tryToGenDeprecatedFlag(Element2 element, {int intent = 0}) {
      if (element is! Annotatable) return;
      final md = (element as Annotatable).metadata2;
      if (!md.hasDeprecated) return;
      final deprecatedFlag = md.annotations.firstWhereOrNull(
        (a) => a.isDeprecated,
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
    for (var method in [
      targetClass.element3.methods2,
      targetClass.allSupertypes.map((t) => t.methods2).expand((e) => e),
    ].expand((e) => e)) {
      if (!method.isPublic ||
          method.isStatic ||
          method.isOperator ||
          generatedMethods.contains(method.name3)) {
        continue;
      }

      final methodName = method.name3;
      if (methodName != null) generatedMethods.add(methodName);

      String generateMethodCall() {
        final methodName = method.name3;

        final positionalParams = <String>[];
        final namedParams = <String>[];
        for (var param in method.formalParameters) {
          final paramName = param.name3;
          if (param.isNamed) {
            namedParams.add('$paramName: $paramName');
          } else if (paramName != null) {
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
    // getters
    for (var getter in targetClass.element3.getters2) {
      if (getter.isStatic) continue;
      final getterName = getter.name3;
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
    // setters
    for (var setter in targetClass.element3.setters2) {
      if (setter.isStatic) continue;
      final setterNameWithEquals = setter.name3;
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

    for (var field in targetClass.element3.fields2) {
      if (field.isStatic || skipBuildFields.contains(field.name3)) continue;
      buffer.writeln('  @override');
      tryToGenDeprecatedFlag(field, intent: 2);
      buffer.writeln(
        '  '
        '${field.type.getDisplayString()} '
        'get ${field.name3} '
        '=> _base.${field.name3};',
      );
      buffer.writeln('');
      if (!field.isFinal) {
        buffer.writeln('  @override');
        tryToGenDeprecatedFlag(field, intent: 2);
        buffer.writeln(
          '  '
          'set ${field.name3}'
          '(${field.type.getDisplayString()} value) '
          '=> _base.${field.name3} = value;',
        );
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
