// Copyright 2023 Fries_I23
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

import 'package:flutter/material.dart' as legacy;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/utils.dart';
import '../../models/habit_color.dart';
import 'theme_with_custom_colors.dart' show ThemeWithCustomColors;

MarkdownConfig _buildThemedMarkdownConfig(BuildContext context) {
  final themeData = Theme.of(context);
  final textTheme = themeData.textTheme;
  final colorScheme = themeData.colorScheme;
  final isDark = themeData.brightness == Brightness.dark;
  final baseConfig = isDark
      ? MarkdownConfig.darkConfig
      : MarkdownConfig.defaultConfig;
  final basePreConfig = isDark ? PreConfig.darkConfig : const PreConfig();
  final bodyStyle = textTheme.bodyMedium ?? const TextStyle();

  return baseConfig.copy(
    configs: [
      PConfig(textStyle: bodyStyle),
      H1Config(
        style: (textTheme.headlineSmall ?? bodyStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      H2Config(
        style: (textTheme.titleLarge ?? bodyStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      H3Config(
        style: (textTheme.titleMedium ?? bodyStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      H4Config(
        style: (textTheme.titleSmall ?? bodyStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      H5Config(style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
      H6Config(
        style: (textTheme.bodySmall ?? bodyStyle).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      basePreConfig.copy(
        textStyle: bodyStyle,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
      CodeConfig(
        style: TextStyle(backgroundColor: colorScheme.surfaceContainerHighest),
      ),
      BlockquoteConfig(
        sideColor: colorScheme.primary.withValues(alpha: 0.5),
        textColor: colorScheme.onSurfaceVariant,
      ),
      LinkConfig(
        style: TextStyle(
          color: colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      HrConfig(color: colorScheme.outlineVariant),
      TableConfig(border: TableBorder.all(color: colorScheme.outlineVariant)),
    ],
  );
}

class ColorfulMarkdownBlock extends StatelessWidget {
  final String data;
  final bool selectable;
  final HabitColor? color;
  final TextScaler? textScaler;

  const ColorfulMarkdownBlock({
    super.key,
    required this.data,
    this.selectable = true,
    this.color,
    this.textScaler,
  });

  MarkdownConfig _getConfig(BuildContext context) {
    final themeData = Theme.of(context);
    return _buildThemedMarkdownConfig(context).copy(
      configs: [
        LinkConfig(
          style: TextStyle(
            color: themeData.colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          onTap: (href) => launchExternalUrl(Uri.parse(href)),
        ),
        // ImgConfig(
        //   builder: (url, attributes) => const SizedBox(),
        // ),
        CheckBoxConfig(
          builder: (checked) => IconTheme(
            data: themeData.iconTheme.copyWith(
              color: themeData.colorScheme.primary,
            ),
            child: MCheckBox(checked: checked),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ThemeWithCustomColors(
    color: color,
    child: MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Builder(
        // Use Builder to apply colorful theme
        builder: (context) => _MarkdownBody(
          data: data,
          selectable: selectable,
          config: _getConfig(context),
        ),
      ),
    ),
  );
}

class ThematicMarkdownBlock extends StatelessWidget {
  final String data;
  final bool selectable;
  final MarkdownConfig Function(MarkdownConfig config)? configBuilder;

  const ThematicMarkdownBlock({
    super.key,
    required this.data,
    this.selectable = true,
    this.configBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final config = _buildThemedMarkdownConfig(context);
    return _MarkdownBody(
      data: data,
      selectable: selectable,
      config: configBuilder?.call(config) ?? config,
    );
  }
}

/// Keeps the remaining legacy Markdown nodes inside their own Material surface.
// FIXME(flutter-ui-compat): Remove this wrapper once markdown_widget uses
// material_ui for its nodes and selection controls.
class _MarkdownBody extends StatelessWidget {
  const _MarkdownBody({
    required this.data,
    required this.selectable,
    required this.config,
  });

  final String data;
  final bool selectable;
  final MarkdownConfig config;

  @override
  Widget build(BuildContext context) {
    // markdown_widget still reads the SDK Theme and builds SDK InkWells. This
    // bridge is local to that dependency; selection and preview routes use the
    // app's Material library instead of inheriting the legacy localization.
    // ignore: deprecated_member_use
    final body = MaterialUiCompatibilityBridge(
      child: legacy.Material(
        type: legacy.MaterialType.transparency,
        child: MarkdownBlock(
          data: data,
          selectable: false,
          config: config,
          generator: MarkdownGenerator(generators: [appMarkdownImageGenerator]),
        ),
      ),
    );
    return selectable ? SelectionArea(child: body) : body;
  }
}

/// Reuses Markdown's image configuration without opening legacy UI routes.
// FIXME(flutter-ui-compat): Remove this image override once markdown_widget's
// default image node and preview use material_ui.
final appMarkdownImageGenerator = SpanNodeGeneratorWithTag(
  tag: MarkdownTag.img.name,
  generator: (element, config, visitor) =>
      _AppMarkdownImageNode(element.attributes, config, visitor),
);

class _AppMarkdownImageNode extends ImageNode {
  _AppMarkdownImageNode(super.attributes, super.config, super.visitor);

  @override
  InlineSpan build() {
    final imageUrl = attributes['src'] ?? '';
    final customImage = imgConfig.builder?.call(imageUrl, attributes);
    if (customImage != null) return WidgetSpan(child: customImage);

    final width = attributes['width'] == null
        ? null
        : double.parse(attributes['width']!);
    final height = attributes['height'] == null
        ? null
        : double.parse(attributes['height']!);
    final alt = attributes['alt'] ?? '';
    Widget onImageError(
      BuildContext context,
      Object error,
      StackTrace? stack,
    ) =>
        imgConfig.errorBuilder?.call(imageUrl, alt, error) ??
        buildErrorImage(imageUrl, alt, error);

    final image = imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: onImageError,
          )
        : Image.asset(
            imageUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: onImageError,
          );

    // The package's LinkNode supplies the outer link gesture for linked images.
    if (parent is LinkNode) return WidgetSpan(child: image);

    final heroTag = Object();
    return WidgetSpan(
      child: Builder(
        builder: (context) => Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => Navigator.of(context).push<void>(
              PageRouteBuilder<void>(
                opaque: false,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    _MarkdownImagePreview(image: image, heroTag: heroTag),
              ),
            ),
            child: Hero(tag: heroTag, child: image),
          ),
        ),
      ),
    );
  }
}

class _MarkdownImagePreview extends StatelessWidget {
  const _MarkdownImagePreview({required this.image, required this.heroTag});

  final Widget image;
  final Object heroTag;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.of(context).pop(),
    child: Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            child: Center(
              child: Hero(tag: heroTag, child: image),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.clear, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
