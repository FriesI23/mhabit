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

import '../../app_changelog/changelog_dialog.dart';

/// Controller that manages the visibility and content of the changelog banner
/// embedded in the habit display sliver list.
class ChangelogBannerController extends ChangeNotifier {
  String _changelogContent = '';
  String _fullChangelog = '';
  String _version = '';
  VoidCallback? _onDismiss;
  bool _isShowing = false;

  bool get isShowing => _isShowing;

  /// Shows the banner with the given [changelogContent], [fullChangelog],
  /// and [version].
  ///
  /// [onDismiss] is called when the banner is dismissed (button tap or swipe).
  void show({
    required String changelogContent,
    required String fullChangelog,
    required String version,
    VoidCallback? onDismiss,
  }) {
    _changelogContent = changelogContent;
    _fullChangelog = fullChangelog;
    _version = version;
    _onDismiss = onDismiss;
    _isShowing = true;
    notifyListeners();
  }

  /// Dismisses the banner and calls [onDismiss] if provided.
  void dismiss() {
    if (!_isShowing) return;
    _isShowing = false;
    final callback = _onDismiss;
    _onDismiss = null;
    notifyListeners();
    callback?.call();
  }

  @override
  void dispose() {
    _onDismiss = null;
    super.dispose();
  }
}

/// A sliver-based changelog banner that embeds directly in a [CustomScrollView].
///
/// Renders inline between the calendar bar and habit list. Banner is always in
/// the tree; [_ChangelogBanner] manages its own expand/collapse animation in
/// response to controller state changes.
class ChangelogBannerSliver extends StatelessWidget {
  final ChangelogBannerController controller;

  const ChangelogBannerSliver({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: _ChangelogBanner(controller: controller));
  }
}

/// Self-contained banner that manages its own expand/collapse animation.
///
/// Always stays in the widget tree. Listens to [ChangelogBannerController]:
/// `show()` → expand, `dismiss()` → collapse. Uses [SizeTransition] following
/// the [ExpandedSection] pattern.
class _ChangelogBanner extends StatefulWidget {
  final ChangelogBannerController controller;

  const _ChangelogBanner({required this.controller});

  @override
  State<_ChangelogBanner> createState() => _ChangelogBannerState();
}

class _ChangelogBannerState extends State<_ChangelogBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0,
    );
    _animation = CurvedAnimation(parent: _anim, curve: Curves.fastOutSlowIn);
    // Start expand after first frame if already showing.
    if (widget.controller.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _anim.forward());
    }
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (widget.controller.isShowing) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => SizeTransition(
        axisAlignment: 1.0,
        sizeFactor: _animation,
        child: Dismissible(
          key: const ValueKey('changelog_banner'),
          direction: DismissDirection.horizontal,
          resizeDuration: null,
          dismissThresholds: const {DismissDirection.horizontal: 0.4},
          onDismissed: (_) => widget.controller.dismiss(),
          child: MaterialBanner(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: const Icon(Icons.celebration_outlined),
            forceActionsBelow: true,
            // TODO(Slice 5): replace with L10n.of(context).changelogBannerContent(version)
            content: Text(
              "v${widget.controller._version} is now available",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  widget.controller.dismiss();
                  showChangelogDialog(
                    context: context,
                    currentVersionSection: widget.controller._changelogContent,
                    fullChangelog: widget.controller._fullChangelog,
                    version: widget.controller._version,
                  );
                },
                child: const Text('VIEW'),
              ),
              TextButton(
                onPressed: widget.controller.dismiss,
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
