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
import '../../component/widget.dart';
import '../../extension/color_extensions.dart';

part 'not_found_image.g.dart';

@CopyWith(skipFields: true)
class NotFoundImageStyle {
  static const inDefault = NotFoundImageStyle(
    backBoardBackgroundColor: Color(0xFFDBF2FF),
    backBoardPaperColor: Color(0xFF4FB4F3),
    fronBoardPaperColor: Color(0xFFACDCFA),
    fronBoardPaperShadowColor: Color(0xFF3594DC),
    magnifierHandleColor: Color(0xFFED3F07),
    magnifierStrokeColor: Color(0xFFF2763D),
  );

  final Color backBoardBackgroundColor;
  final Color backBoardPaperColor;
  final Color fronBoardPaperColor;
  final Color fronBoardPaperShadowColor;
  final Color magnifierHandleColor;
  final Color magnifierStrokeColor;

  const NotFoundImageStyle({
    required this.backBoardBackgroundColor,
    required this.backBoardPaperColor,
    required this.fronBoardPaperColor,
    required this.fronBoardPaperShadowColor,
    required this.magnifierHandleColor,
    required this.magnifierStrokeColor,
  });
}

class _Key {
  static const backBoardBackgroundColor = "color1";
  static const backBoardPaperColor = "color2";
  static const fronBoardPaperColor = "color3";
  static const fronBoardPaperShadowColor = "color4";
  static const magnifierHandleColor = "color5";
  static const magnifierStrokeColor = "color6";
}

class NotFoundImage extends StatelessWidget {
  final Size? size;
  final EdgeInsetsGeometry? padding;
  final String? imagePath;
  final Widget? descChild;
  final NotFoundImageStyle? style;

  const NotFoundImage({
    super.key,
    this.size,
    this.padding,
    this.imagePath,
    this.descChild,
    this.style,
  });

  NotFoundImageStyle get _defaultStyle => NotFoundImageStyle.inDefault;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

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
                label: 'not-found-image',
                svgTemplatePath: imagePath ?? Assets.images.notFoundSvg,
                svgTemplateFormat: {
                  _Key.backBoardBackgroundColor:
                      (style?.backBoardBackgroundColor ??
                              _defaultStyle.backBoardBackgroundColor)
                          .toHex(),
                  _Key.backBoardPaperColor: (style?.backBoardPaperColor ??
                          _defaultStyle.backBoardPaperColor)
                      .toHex(),
                  _Key.fronBoardPaperColor: (style?.fronBoardPaperColor ??
                          _defaultStyle.fronBoardPaperColor)
                      .toHex(),
                  _Key.fronBoardPaperShadowColor:
                      (style?.fronBoardPaperShadowColor ??
                              _defaultStyle.fronBoardPaperShadowColor)
                          .toHex(),
                  _Key.magnifierHandleColor: (style?.magnifierHandleColor ??
                          _defaultStyle.magnifierHandleColor)
                      .toHex(),
                  _Key.magnifierStrokeColor: (style?.magnifierStrokeColor ??
                          _defaultStyle.magnifierStrokeColor)
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
