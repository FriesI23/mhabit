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

import '../../../assets/assets.dart';
import '../../../extensions/color_extensions.dart';
import '../../../widgets/widgets.dart';

part 'today_done_image.g.dart';

@CopyWith(skipFields: true)
class TodayDoneImageStyle {
  static const inDefault = TodayDoneImageStyle(
    laserColor: Color(0x00E3C250),
    sunColor: Color(0x00F9CB41),
    horizonColor: Color(0x001CE5F0),
  );

  final Color laserColor;
  final Color sunColor;
  final Color horizonColor;

  const TodayDoneImageStyle({
    required this.laserColor,
    required this.sunColor,
    required this.horizonColor,
  });
}

class _Key {
  static const laserColor = "color1";
  static const sunColor = "color2";
  static const horizonColor = "color3";
}

class TodayDoneImage extends StatelessWidget {
  final String? label;
  final Size? size;
  final EdgeInsetsGeometry? padding;
  final String? imagePath;
  final Widget? descChild;
  final TodayDoneImageStyle? style;

  const TodayDoneImage({
    super.key,
    this.label,
    this.size,
    this.padding,
    this.imagePath,
    this.descChild,
    this.style,
  });

  TodayDoneImageStyle get _defaultStyle => TodayDoneImageStyle.inDefault;

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
                label: label,
                svgTemplatePath: imagePath ?? Assets.images.todayDoneSvg,
                svgTemplateFormat: {
                  _Key.laserColor:
                      (style?.laserColor ?? _defaultStyle.laserColor).toHex(),
                  _Key.sunColor:
                      (style?.sunColor ?? _defaultStyle.sunColor).toHex(),
                  _Key.horizonColor:
                      (style?.horizonColor ?? _defaultStyle.horizonColor)
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
