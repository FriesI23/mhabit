// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../assets/assets.gen.dart';

/// Plays the Buy Me a Coffee animation once per widget instance.
///
/// Playback respects ancestor [TickerMode] and reduced motion. Lazy scrolling
/// parents retain its progress; each instance owns an independent image stream.
/// This is a decorative icon with no accessibility label.
class BuyMeACoffeeIcon extends StatefulWidget {
  const BuyMeACoffeeIcon({
    super.key,
    this.size = 40,
    this.animated = true,
    this.fallback,
  });

  /// Square extent in logical pixels, including the fallback.
  final double size;

  /// Whether playback may advance. Pausing preserves the current frame.
  final bool animated;

  /// Shown while loading or on failure; defaults to a static coffee icon.
  final Widget? fallback;

  @override
  State<BuyMeACoffeeIcon> createState() => _BuyMeACoffeeIconState();
}

class _BuyMeACoffeeIconState extends State<BuyMeACoffeeIcon>
    with AutomaticKeepAliveClientMixin {
  Future<MemoryImage?>? _loading;
  MemoryImage? _image;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loading ??= _loadImage(DefaultAssetBundle.of(context));
  }

  Future<MemoryImage?> _loadImage(AssetBundle bundle) async {
    final bytes = await bundle.load(Assets.images.appSupportCoffee.path);
    if (!mounted) return null;
    // MemoryImage keys compare bytes by identity. Copy once so image caching
    // cannot synchronize playback between independently mounted icons.
    return _image = MemoryImage(
      Uint8List.fromList(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      ),
    );
  }

  @override
  void dispose() {
    final image = _image;
    if (image != null) unawaited(image.evict());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fallback =
        widget.fallback ?? Icon(Icons.coffee_rounded, size: widget.size);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size,
        child: TickerMode(
          enabled: widget.animated,
          child: FutureBuilder<MemoryImage?>(
            future: _loading,
            builder: (context, snapshot) {
              final image = snapshot.data;
              return image == null
                  ? fallback
                  : Image(
                      image: image,
                      width: widget.size,
                      height: widget.size,
                      excludeFromSemantics: true,
                      errorBuilder: (context, error, stackTrace) => fallback,
                    );
            },
          ),
        ),
      ),
    );
  }
}
