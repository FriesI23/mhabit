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

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

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
        builder: (context) => MarkdownBlock(
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
    return MarkdownBlock(
      data: data,
      selectable: selectable,
      config: configBuilder?.call(config) ?? config,
    );
  }
}
