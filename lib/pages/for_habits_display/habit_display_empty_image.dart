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

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/material.dart';

import '../../assets/assets.dart';
import '../../extension/color_extensions.dart';
import '../../widgets/widgets.dart';

part 'habit_display_empty_image.g.dart';

@CopyWith(skipFields: true)
class HabitDisplayEmptyImageStyle {
  static const inDefault = HabitDisplayEmptyImageStyle(
    backBoardBackgroundColor: Color(0xFFE1E2E4),
    fronBoardBackgroundColor: Color(0xFFFDFCFC),
    boardStrokeColor: Color(0xFF8F9193),
    fronBoardTopColor: Color(0xFF61D4FF),
    fronBoardFirstLineColor: Color(0xFFBCE9FF),
    fronBoardOtherLineColor: Color(0xFFC1C7CE),
    fronBoardSubtitleLineColor: Color(0xFFEFF1F3),
    backgroundCirlcColor: Color(0xFFEFF1F3),
  );

  final Color backBoardBackgroundColor;
  final Color fronBoardBackgroundColor;
  final Color boardStrokeColor;
  final Color fronBoardTopColor;
  final Color fronBoardFirstLineColor;
  final Color fronBoardOtherLineColor;
  final Color fronBoardSubtitleLineColor;
  final Color backgroundCirlcColor;

  const HabitDisplayEmptyImageStyle({
    required this.backBoardBackgroundColor,
    required this.fronBoardBackgroundColor,
    required this.boardStrokeColor,
    required this.fronBoardTopColor,
    required this.fronBoardFirstLineColor,
    required this.fronBoardOtherLineColor,
    required this.fronBoardSubtitleLineColor,
    required this.backgroundCirlcColor,
  });
}

class _Key {
  static const backBoardBackgroundColor = "color1";
  static const fronBoardBackgroundColor = "color2";
  static const boardStrokeColor = "color3";
  static const fronBoardTopColor = "color4";
  static const fronBoardFirstLineColor = "color5";
  static const fronBoardOtherLineColor = "color6";
  static const fronBoardSubtitleLineColor = "color7";
  static const backgroundCirlcColor = "color8";
}

class HabitDisplayEmptyImage extends StatelessWidget {
  final Size? size;
  final EdgeInsetsGeometry? padding;
  final String? imagePath;
  final Widget? descChild;
  final HabitDisplayEmptyImageStyle? style;

  const HabitDisplayEmptyImage({
    super.key,
    this.size,
    this.padding,
    this.imagePath,
    this.descChild,
    this.style,
  });

  HabitDisplayEmptyImageStyle get _defaultStyle =>
      HabitDisplayEmptyImageStyle.inDefault;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    Widget buildDescChild(BuildContext context) {
      if (textTheme.headlineSmall != null) {
        return DefaultTextStyle(
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall!
                .copyWith(color: theme.colorScheme.outline),
            child: descChild!);
      }
      return descChild!;
    }

    return Container(
      alignment: Alignment.center,
      padding: padding,
      child: FittedBox(
        child: SizedBox(
          width: size?.width,
          child: Column(
            children: [
              SvgTemplateImage(
                size: size,
                label: 'habit-display-empty-image',
                svgTemplatePath: imagePath ?? Assets.images.emptyHabitsSvg,
                svgTemplateFormat: {
                  _Key.backBoardBackgroundColor:
                      (style?.backBoardBackgroundColor ??
                              _defaultStyle.backBoardBackgroundColor)
                          .toHex(),
                  _Key.fronBoardBackgroundColor:
                      (style?.fronBoardBackgroundColor ??
                              _defaultStyle.fronBoardBackgroundColor)
                          .toHex(),
                  _Key.boardStrokeColor: (style?.boardStrokeColor ??
                          _defaultStyle.boardStrokeColor)
                      .toHex(),
                  _Key.fronBoardTopColor: (style?.fronBoardTopColor ??
                          _defaultStyle.fronBoardTopColor)
                      .toHex(),
                  _Key.fronBoardFirstLineColor:
                      (style?.fronBoardFirstLineColor ??
                              _defaultStyle.fronBoardFirstLineColor)
                          .toHex(),
                  _Key.fronBoardOtherLineColor:
                      (style?.fronBoardOtherLineColor ??
                              _defaultStyle.fronBoardOtherLineColor)
                          .toHex(),
                  _Key.fronBoardSubtitleLineColor:
                      (style?.fronBoardSubtitleLineColor ??
                              _defaultStyle.fronBoardSubtitleLineColor)
                          .toHex(),
                  _Key.backgroundCirlcColor: (style?.backgroundCirlcColor ??
                          _defaultStyle.backgroundCirlcColor)
                      .toHex(),
                },
              ),
              if (descChild != null) buildDescChild(context),
            ],
          ),
        ),
      ),
    );
  }
}
