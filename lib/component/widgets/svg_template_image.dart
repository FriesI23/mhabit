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
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/logging.dart';
import '../../common/utils.dart';

class SvgTemplateImage extends StatefulWidget {
  static const emptySVGString =
      '<svg xmlns="http://www.w3.org/2000/svg" width="0" height="0"></svg>';

  final Size? size;
  final String? label;
  final String svgTemplatePath;
  final Map<String, dynamic>? svgTemplateFormat;

  const SvgTemplateImage({
    super.key,
    this.label,
    this.size,
    required this.svgTemplatePath,
    this.svgTemplateFormat,
  });

  @override
  State<StatefulWidget> createState() => _SvgTemplateImage();
}

class _SvgTemplateImage extends State<SvgTemplateImage> {
  Future<String>? _future;

  String formatSVGTemplate(String templateString) {
    return widget.svgTemplateFormat == null
        ? templateString
        : TemplateString(templateString).format(widget.svgTemplateFormat!);
  }

  Future<String> loadImage(BuildContext context) async {
    if (_future != null) return _future!;
    DebugLog.load("SvgTemplateImage:: load from ${widget.svgTemplatePath}");
    _future = DefaultAssetBundle.of(context).loadString(widget.svgTemplatePath);
    return _future!;
  }

  @override
  void didUpdateWidget(covariant SvgTemplateImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.svgTemplatePath != widget.svgTemplatePath) {
      _future = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      initialData: SvgTemplateImage.emptySVGString,
      future: loadImage(context),
      builder: (context, snapshot) {
        return SvgPicture.string(
          formatSVGTemplate(snapshot.data!),
          semanticsLabel: widget.label,
          width: widget.size?.width,
          height: widget.size?.height,
        );
      },
    );
  }
}
