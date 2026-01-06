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
import '../../models/habit_form.dart';
import 'theme_with_custom_colors.dart' show ThemeWithCustomColors;

class ColorfulMarkdownBlock extends StatelessWidget {
  final String data;
  final bool selectable;
  final HabitColorType? colorType;
  final TextScaler? textScaler;

  const ColorfulMarkdownBlock({
    super.key,
    required this.data,
    this.selectable = true,
    this.colorType,
    this.textScaler,
  });

  MarkdownConfig _getConfig(BuildContext context) {
    final themeData = Theme.of(context);
    final isDark = themeData.brightness == Brightness.dark;
    final config = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;

    return config.copy(
      configs: [
        isDark ? PreConfig.darkConfig : const PreConfig(),
        BlockquoteConfig(
          sideColor: themeData.colorScheme.primary.withValues(alpha: 0.5),
          textColor: themeData.colorScheme.onSurface.withValues(alpha: 0.8),
        ),
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
    colorType: colorType,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    return MarkdownBlock(
      data: data,
      selectable: selectable,
      config: configBuilder?.call(config) ?? config,
    );
  }
}
