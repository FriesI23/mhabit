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
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../common/utils.dart';
import '../../model/habit_form.dart';
import '../widget.dart';

class ThematicMarkdownBody extends StatelessWidget {
  final String data;
  final HabitColorType? colorType;
  final TextScaler? textScaler;
  final MarkdownImageBuilder? imageBuilder;
  final MarkdownTapLinkCallback? onTapLink;

  const ThematicMarkdownBody({
    super.key,
    required this.data,
    this.colorType,
    this.textScaler,
    this.imageBuilder,
    this.onTapLink,
  });

  MarkdownStyleSheet _getStyleSheet(BuildContext context) {
    final themeData = Theme.of(context);
    return MarkdownStyleSheet.fromTheme(themeData).copyWith(
      textScaler: textScaler ?? MediaQuery.textScalerOf(context),
      a: TextStyle(color: themeData.colorScheme.primary),
      blockquote: themeData.textTheme.bodyMedium!
          .copyWith(color: themeData.colorScheme.primary),
      blockquoteDecoration: BoxDecoration(
        color: themeData.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(2.0),
      ),
      checkbox: themeData.textTheme.bodyMedium!.copyWith(
        color: themeData.colorScheme.primary,
      ),
    );
  }

  Widget _defaultImageBuilder(Uri uri, String? title, String? alt) =>
      const SizedBox();

  void _defaultTapLinkCallback(String text, String? href, String title) =>
      href != null ? launchExternalUrl(Uri.parse(href)) : null;

  @override
  Widget build(BuildContext context) {
    return ThemeWithCustomColors(
      colorType: colorType,
      child: Builder(builder: (context) {
        return MarkdownBody(
          data: data,
          styleSheet: _getStyleSheet(context),
          shrinkWrap: true,
          imageBuilder: imageBuilder ?? _defaultImageBuilder,
          onTapLink: onTapLink ?? _defaultTapLinkCallback,
        );
      }),
    );
  }
}
