// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $ConfigsGen {
  const $ConfigsGen();

  /// File path: configs/about_info.json
  String get aboutInfo => 'configs/about_info.json';

  /// File path: configs/contributors.json
  String get contributors => 'configs/contributors.json';

  /// List of all assets
  List<String> get values => [aboutInfo, contributors];
}

class $DocsGen {
  const $DocsGen();

  /// Directory path: docs/CHANGELOG
  $DocsCHANGELOGGen get changelog => const $DocsCHANGELOGGen();
}

class $AssetsIconsGen {
  const $AssetsIconsGen();
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/donate-alipay.jpg
  AssetGenImage get donateAlipay =>
      const AssetGenImage('assets/images/donate-alipay.jpg');

  /// File path: assets/images/donate-wechatpay.png
  AssetGenImage get donateWechatpay =>
      const AssetGenImage('assets/images/donate-wechatpay.png');

  /// File path: assets/images/empty-habits.svg
  SvgGenImage get emptyHabits =>
      const SvgGenImage('assets/images/empty-habits.svg');

  /// File path: assets/images/empty-habits.svg.template
  String get emptyHabitsSvg => 'assets/images/empty-habits.svg.template';

  /// File path: assets/images/not-found.svg
  SvgGenImage get notFound => const SvgGenImage('assets/images/not-found.svg');

  /// File path: assets/images/not-found.svg.template
  String get notFoundSvg => 'assets/images/not-found.svg.template';

  /// List of all assets
  List<dynamic> get values => [
        donateAlipay,
        donateWechatpay,
        emptyHabits,
        emptyHabitsSvg,
        notFound,
        notFoundSvg
      ];
}

class $AssetsLogoGen {
  const $AssetsLogoGen();

  /// File path: assets/logo/icon-momo.svg
  SvgGenImage get iconMomo => const SvgGenImage('assets/logo/icon-momo.svg');

  /// List of all assets
  List<SvgGenImage> get values => [iconMomo];
}

class $AssetsSqlGen {
  const $AssetsSqlGen();

  /// File path: assets/sql/indexes.sql
  String get indexes => 'assets/sql/indexes.sql';

  /// File path: assets/sql/mh_habits.sql
  String get mhHabits => 'assets/sql/mh_habits.sql';

  /// File path: assets/sql/mh_records.sql
  String get mhRecords => 'assets/sql/mh_records.sql';

  /// File path: assets/sql/mh_sync.sql
  String get mhSync => 'assets/sql/mh_sync.sql';

  /// File path: assets/sql/mh_sync_indexes.sql
  String get mhSyncIndexes => 'assets/sql/mh_sync_indexes.sql';

  /// List of all assets
  List<String> get values =>
      [indexes, mhHabits, mhRecords, mhSync, mhSyncIndexes];
}

class $DocsCHANGELOGGen {
  const $DocsCHANGELOGGen();

  /// File path: docs/CHANGELOG/zh.md
  String get zh => 'docs/CHANGELOG/zh.md';

  /// List of all assets
  List<String> get values => [zh];
}

class Assets {
  const Assets._();

  static const String changelog = 'CHANGELOG.md';
  static const String license = 'LICENSE';
  static const String licenseThirdparty = 'LICENSE_THIRDPARTY.md';
  static const String privacy = 'PRIVACY.md';
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsLogoGen logo = $AssetsLogoGen();
  static const $AssetsSqlGen sql = $AssetsSqlGen();
  static const $ConfigsGen configs = $ConfigsGen();
  static const $DocsGen docs = $DocsGen();

  /// List of all assets
  static List<String> get values =>
      [changelog, license, licenseThirdparty, privacy];
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
