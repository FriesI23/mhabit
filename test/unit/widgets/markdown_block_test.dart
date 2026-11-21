// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.

import 'package:flutter/material.dart' as legacy;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mhabit/common/consts.dart';
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

Future<void> _mountMarkdown(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? _theme(),
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      home: Scaffold(body: SizedBox(width: 180, child: child)),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _settleImages(WidgetTester tester) async {
  final images = tester.widgetList<Image>(find.byType(Image)).toList();
  await tester.runAsync(() async {
    for (final image in images) {
      await precacheImage(
        image.image,
        tester.element(find.byType(Image).first),
        onError: (error, stack) {},
      );
    }
  });
  await tester.pumpAndSettle();
}

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

  testWidgets('selection uses the app Material library and remains optional', (
    tester,
  ) async {
    await _mountMarkdown(
      tester,
      const ThematicMarkdownBlock(data: 'Selectable body'),
    );
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(find.byType(legacy.SelectionArea), findsNothing);
    expect(
      tester.widget<MarkdownBlock>(find.byType(MarkdownBlock)).selectable,
      isFalse,
    );
    expect(find.byType(legacy.Material), findsOneWidget);

    await _mountMarkdown(
      tester,
      const ThematicMarkdownBlock(data: 'Static body', selectable: false),
    );
    expect(find.byType(SelectionArea), findsNothing);
  });

  for (final locale in [
    const Locale('en'),
    const Locale('eo'),
    const Locale('ar'),
  ]) {
    testWidgets('legacy nodes keep dark theme and $locale direction', (
      tester,
    ) async {
      await _mountMarkdown(
        tester,
        const ThematicMarkdownBlock(data: '- First\n- Second'),
        locale: locale,
        theme: ThemeData.dark(),
      );
      final context = tester.element(find.byType(MarkdownBlock));
      expect(legacy.Theme.of(context).brightness, Brightness.dark);
      expect(
        legacy.Theme.of(context).textTheme.bodyMedium,
        Theme.of(context).textTheme.bodyMedium,
      );
      expect(
        Directionality.of(context),
        locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('text links keep the configured external URL callback', (
    tester,
  ) async {
    String? opened;
    await _mountMarkdown(
      tester,
      ThematicMarkdownBlock(
        data: '[Open docs](https://example.com/docs)',
        configBuilder: (config) =>
            config.copy(configs: [LinkConfig(onTap: (url) => opened = url)]),
      ),
    );
    await tester.tapAt(
      tester.getTopLeft(find.textContaining('Open docs')) + const Offset(8, 8),
    );
    await tester.pump();
    expect(opened, 'https://example.com/docs');
    expect(tester.takeException(), isNull);
  });

  testWidgets('linked images follow their URL instead of opening a preview', (
    tester,
  ) async {
    String? opened;
    await _mountMarkdown(
      tester,
      ThematicMarkdownBlock(
        data: '[![Picture](assets/icons/uhabit_icon.png)](https://example.com)',
        configBuilder: (config) =>
            config.copy(configs: [LinkConfig(onTap: (url) => opened = url)]),
      ),
    );
    await _settleImages(tester);
    await tester.tap(find.byType(Image));
    await tester.pumpAndSettle();
    expect(opened, 'https://example.com');
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final closeButton in [true, false]) {
    testWidgets('standalone image preview closes with button=$closeButton', (
      tester,
    ) async {
      await _mountMarkdown(
        tester,
        const ThematicMarkdownBlock(
          data: '![Picture](assets/icons/uhabit_icon.png)',
        ),
        locale: const Locale('eo'),
        theme: ThemeData.dark(),
      );
      await _settleImages(tester);
      await tester.tap(find.byType(Image));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byType(InteractiveViewer),
          matching: find.byType(Scaffold),
        ),
        findsOneWidget,
      );
      expect(find.byType(legacy.Scaffold), findsNothing);
      expect(tester.takeException(), isNull);
      if (closeButton) {
        await tester.tap(find.byIcon(Icons.clear));
      } else {
        final context = tester.element(find.byType(InteractiveViewer));
        expect(await Navigator.of(context).maybePop(), isTrue);
      }
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsNothing);
      expect(find.byType(MarkdownBlock), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('custom image configuration is retained by the app image node', (
    tester,
  ) async {
    String? imageUrl;
    Map<String, String>? imageAttributes;
    final config = MarkdownConfig(
      configs: [
        ImgConfig(
          builder: (url, attributes) {
            imageUrl = url;
            imageAttributes = attributes;
            return const Text('Custom image');
          },
        ),
      ],
    );
    final element = markdown.Element.empty('img')
      ..attributes.addAll({'src': 'custom.png', 'width': '32', 'height': '24'});
    final node = appMarkdownImageGenerator.generator(
      element,
      config,
      WidgetVisitor(config: config),
    );
    await _mountMarkdown(tester, Text.rich(node.build()));
    expect(imageUrl, 'custom.png');
    expect(imageAttributes?['width'], '32');
    expect(imageAttributes?['height'], '24');
    expect(find.text('Custom image'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('image dimensions and configured error output are preserved', (
    tester,
  ) async {
    final errors = <(String, String)>[];
    final config = MarkdownConfig(
      configs: [
        ImgConfig(
          errorBuilder: (url, alt, error) {
            errors.add((url, alt));
            return Text(alt);
          },
        ),
      ],
    );
    final element = markdown.Element.empty('img')
      ..attributes.addAll({
        'src': 'assets/missing-markdown-image.png',
        'alt': 'Missing picture',
        'width': '32',
        'height': '24',
      });
    final node = appMarkdownImageGenerator.generator(
      element,
      config,
      WidgetVisitor(config: config),
    );
    await _mountMarkdown(tester, Text.rich(node.build()));
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 32);
    expect(image.height, 24);
    await _settleImages(tester);
    expect(find.text('Missing picture'), findsOneWidget);
    expect(errors, isNotEmpty);
    expect(
      errors.every(
        (entry) =>
            entry == ('assets/missing-markdown-image.png', 'Missing picture'),
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected Markdown text can be copied', (tester) async {
    final clipboard = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard.add((call.arguments as Map)['text'] as String);
        } else if (call.method == 'Clipboard.getData') {
          return {'text': clipboard.isEmpty ? '' : clipboard.last};
        } else if (call.method == 'Clipboard.hasStrings') {
          return {'value': clipboard.isNotEmpty};
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _mountMarkdown(
      tester,
      const ThematicMarkdownBlock(data: 'Selectable Markdown text'),
    );
    await tester.longPress(find.textContaining('Selectable Markdown text'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy').last);
    await tester.pumpAndSettle();
    expect(clipboard, hasLength(1));
    expect(clipboard.single, isNotEmpty);
    expect('Selectable Markdown text'.contains(clipboard.single), isTrue);
    expect(tester.takeException(), isNull);
  });
}
