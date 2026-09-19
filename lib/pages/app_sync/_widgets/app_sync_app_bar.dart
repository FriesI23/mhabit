// Copyright 2026 Fries_I23
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
import 'package:flutter/rendering.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../extensions/adaptive_style_extensions.dart';
import '../../../providers/workflow/app_sync.dart';
import '../../../widgets/widgets.dart' show EnhancedSafeArea, L10nBuilder;

class AppSyncAppBar extends StatelessWidget {
  const AppSyncAppBar({super.key});

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.material => const _MaterialAppSyncAppBar(),
    AdaptiveStyle.apple => const _AppleAppSyncAppBar(),
  };
}

class _MaterialAppSyncAppBar extends StatelessWidget {
  const _MaterialAppSyncAppBar();

  @override
  Widget build(BuildContext context) => _MeasuredSyncAppBar(
    appBarBuilder: (bottom) => AdaptiveSliverAppBar.material(
      height: AppAdaptiveStyle.materialToolbarHeight,
      styles: const AppBarStyles(
        material: AppBarMaterialStyle(
          floating: false,
          snap: false,
          pinned: true,
        ),
      ),
      leading: const AdaptiveBackButton(type: AdaptiveBackButtonType.back),
      title: const _SyncAppBarTitle(),
      bottom: bottom,
    ),
    child: _SyncEnableBinding(
      builder: (title, value, onChanged) => AdaptiveSwitchListTile.material(
        title: title,
        value: value,
        onChanged: onChanged,
      ),
    ),
  );
}

class _AppleAppSyncAppBar extends StatelessWidget {
  const _AppleAppSyncAppBar();

  @override
  Widget build(BuildContext context) => _MeasuredSyncAppBar(
    appBarBuilder: (bottom) => AdaptiveSliverAppBar.apple(
      height: AppAdaptiveStyle.appleToolbarHeight,
      leading: const AdaptiveBackButton(type: AdaptiveBackButtonType.back),
      title: const _SyncAppBarTitle(),
      bottom: bottom,
    ),
    child: _SyncEnableBinding(
      builder: (title, value, onChanged) => AdaptiveSwitchListTile.apple(
        title: title,
        value: value,
        onChanged: onChanged,
      ),
    ),
  );
}

class _SyncAppBarTitle extends StatelessWidget {
  const _SyncAppBarTitle();

  @override
  Widget build(BuildContext context) => L10nBuilder(
    builder: (context, l10n) =>
        Text(l10n?.appSetting_syncOption_titleText ?? 'Sync'),
  );
}

class _SyncEnableBinding extends StatelessWidget {
  const _SyncEnableBinding({required this.builder});

  final Widget Function(Widget title, bool value, ValueChanged<bool> onChanged)
  builder;

  @override
  Widget build(BuildContext context) => Selector<AppSyncSettingsAccess, bool>(
    selector: (ctx, v) => v.enabled,
    builder: (context, value, child) => builder(
      L10nBuilder(
        builder: (context, l10n) => Text(l10n?.common_enable_text ?? 'Enable'),
      ),
      value,
      (value) => context.read<AppSyncSettingsAccess>().setSyncSwitch(value),
    ),
  );
}

// AppBar.bottom requires a preferred extent. Measure the live row with its
// actual theme, width, safe area and text scale rather than estimating SDK sizes.
class _MeasuredSyncAppBar extends StatefulWidget {
  const _MeasuredSyncAppBar({required this.appBarBuilder, required this.child});

  final Widget Function(PreferredSizeWidget bottom) appBarBuilder;
  final Widget child;

  @override
  State<_MeasuredSyncAppBar> createState() => _MeasuredSyncAppBarState();
}

class _MeasuredSyncAppBarState extends State<_MeasuredSyncAppBar> {
  double _height = kToolbarHeight;

  void _onHeightChanged(double height) {
    if (!mounted || height == _height) return;
    setState(() => _height = height);
  }

  @override
  Widget build(BuildContext context) => widget.appBarBuilder(
    PreferredSize(
      preferredSize: Size.fromHeight(_height),
      child: SizedBox(
        height: _height,
        child: ClipRect(
          child: OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            child: _EnableHeightReporter(
              onHeightChanged: _onHeightChanged,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kToolbarHeight),
                child: EnhancedSafeArea.symmetric(
                  horizontal: true,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _EnableHeightReporter extends SingleChildRenderObjectWidget {
  const _EnableHeightReporter({
    required this.onHeightChanged,
    required super.child,
  });

  final ValueChanged<double> onHeightChanged;

  @override
  _RenderEnableHeightReporter createRenderObject(BuildContext context) =>
      _RenderEnableHeightReporter(onHeightChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderEnableHeightReporter renderObject,
  ) {
    renderObject.onHeightChanged = onHeightChanged;
  }
}

class _RenderEnableHeightReporter extends RenderProxyBox {
  _RenderEnableHeightReporter(this.onHeightChanged);

  ValueChanged<double> onHeightChanged;
  double? _reportedHeight;
  bool _pending = false;

  @override
  void performLayout() {
    super.performLayout();
    if (_pending || size.height == _reportedHeight) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      if (!attached) return;
      final height = size.height;
      if (height == _reportedHeight) return;
      _reportedHeight = height;
      onHeightChanged(height);
    });
  }
}
