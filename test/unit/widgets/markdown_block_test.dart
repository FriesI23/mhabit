// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:mhabit/models/habit_color.dart';
import 'package:mhabit/theme/color.dart';
import 'package:mhabit/widgets/widgets.dart';

const _bodyStyle = TextStyle(fontSize: 13, height: 1.3);
const _bodySmallStyle = TextStyle(fontSize: 11, height: 1.2);
const _titleSmallStyle = TextStyle(fontSize: 15, height: 1.2);
const _titleMediumStyle = TextStyle(fontSize: 17, height: 1.2);
const _titleLargeStyle = TextStyle(fontSize: 21, height: 1.2);
const _headlineSmallStyle = TextStyle(fontSize: 25, height: 1.2);

const _colorScheme = ColorScheme.light(
  primary: Color(0xff123456),
  onSurfaceVariant: Color(0xff234567),
  surfaceContainer: Color(0xff345678),
  surfaceContainerHighest: Color(0xff456789),
  outlineVariant: Color(0xff56789a),
);

ThemeData _theme({List<ThemeExtension<dynamic>> extensions = const []}) =>
    ThemeData(
      colorScheme: _colorScheme,
      textTheme: const TextTheme(
        bodyMedium: _bodyStyle,
        bodySmall: _bodySmallStyle,
        titleSmall: _titleSmallStyle,
        titleMedium: _titleMediumStyle,
        titleLarge: _titleLargeStyle,
        headlineSmall: _headlineSmallStyle,
      ),
      extensions: extensions,
    );

MarkdownConfig _config(WidgetTester tester) =>
    tester.widget<MarkdownBlock>(find.byType(MarkdownBlock)).config!;

void _expectAppThemeConfig(
  MarkdownConfig config, {
  required TextTheme textTheme,
  required Color primary,
}) {
  expect(config.p.textStyle, textTheme.bodyMedium);
  expect(config.h1.style.fontSize, textTheme.headlineSmall?.fontSize);
  expect(config.h2.style.fontSize, textTheme.titleLarge?.fontSize);
  expect(config.h3.style.fontSize, textTheme.titleMedium?.fontSize);
  expect(config.h4.style.fontSize, textTheme.titleSmall?.fontSize);
  expect(config.h5.style.fontSize, textTheme.bodyMedium?.fontSize);
  expect(config.h6.style.fontSize, textTheme.bodySmall?.fontSize);
  for (final heading in [
    config.h1,
    config.h2,
    config.h3,
    config.h4,
    config.h5,
    config.h6,
  ]) {
    expect(heading.style.fontWeight, FontWeight.bold);
  }
  expect(config.a.style.color, primary);
  expect(config.blockquote.textColor, _colorScheme.onSurfaceVariant);
  expect(config.blockquote.sideColor, primary.withValues(alpha: 0.5));
  expect(config.pre.textStyle, textTheme.bodyMedium);
  expect(
    (config.pre.decoration as BoxDecoration).color,
    _colorScheme.surfaceContainer,
  );
  expect(
    config.code.style.backgroundColor,
    _colorScheme.surfaceContainerHighest,
  );
  expect(config.hr.color, _colorScheme.outlineVariant);
  expect(config.table.border?.top.color, _colorScheme.outlineVariant);
}

void main() {
  testWidgets('ThematicMarkdownBlock derives config from the app theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(),
        home: const Scaffold(
          body: ThematicMarkdownBlock(data: '# Heading\n\nBody'),
        ),
      ),
    );

    final markdownContext = tester.element(find.byType(MarkdownBlock));
    _expectAppThemeConfig(
      _config(tester),
      textTheme: Theme.of(markdownContext).textTheme,
      primary: _colorScheme.primary,
    );
  });

  testWidgets('ColorfulMarkdownBlock resolves config inside its color theme', (
    tester,
  ) async {
    const habitPrimary = Color(0xff336699);
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(extensions: [lightCustomColors]),
        home: const Scaffold(
          body: ColorfulMarkdownBlock(
            data: '[Link](https://example.com)',
            color: HabitColor.custom(0xff336699, tinted: false),
          ),
        ),
      ),
    );

    final markdownContext = tester.element(find.byType(MarkdownBlock));
    _expectAppThemeConfig(
      _config(tester),
      textTheme: Theme.of(markdownContext).textTheme,
      primary: habitPrimary,
    );
  });

  testWidgets(
    'caller configBuilder overrides the shared Markdown config last',
    (tester) async {
      const overrideStyle = TextStyle(fontSize: 91);
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme(),
          home: Scaffold(
            body: ThematicMarkdownBlock(
              data: 'Body',
              configBuilder: (config) => config.copy(
                configs: [const PConfig(textStyle: overrideStyle)],
              ),
            ),
          ),
        ),
      );

      expect(_config(tester).p.textStyle, overrideStyle);
    },
  );
}
