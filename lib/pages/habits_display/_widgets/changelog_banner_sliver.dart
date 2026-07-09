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
import 'package:flutter/services.dart' show rootBundle;

import '../../../common/app_info.dart';
import '../../../extensions/asset_bundle_extensions.dart';
import '../../../l10n/localizations.dart';
import '../../app_changelog/changelog_dialog.dart';
import '../../app_changelog/changelog_parser.dart';

/// App-level manager for the changelog banner.
///
/// Place above [HabitsDisplayPage] in the widget tree. Use
/// [ChangelogBanner.of] to trigger the banner from anywhere in the subtree —
/// this follows the same pattern as [ScaffoldMessenger.of].
///
/// ```dart
/// ChangelogBanner(
///   child: HabitsDisplayPage(),
/// )
/// ```
///
/// Then trigger from anywhere below:
/// ```dart
/// ChangelogBanner.of(context).show(
///   changelogContent: '...',
///   fullChangelog: '...',
///   version: '1.0.0+1',
/// );
/// ```
class ChangelogBanner extends StatefulWidget {
  final Widget child;

  const ChangelogBanner({super.key, required this.child});

  /// Returns the [ChangelogBannerState] for the nearest [ChangelogBanner]
  /// ancestor. Throws if none found — mirroring [ScaffoldMessenger.of].
  static ChangelogBannerState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_ChangelogBannerScope>();
    assert(scope != null, 'No ChangelogBanner found in widget tree');
    return scope!.state;
  }

  @override
  State<ChangelogBanner> createState() => ChangelogBannerState();
}

/// Loads CHANGELOG.md and shows the banner for the current app version.
///
/// Handles version lookup, CHANGELOG loading, and version-section extraction
/// (delegated to [extractVersionSectionWithFallback]).
/// Optionally override [version] and provide [onDismiss] callback.
/// Set [useLatestFallback] to `true` to show the latest changelog section
/// when version matching fails (manual triggers only).
Future<void> showChangelogBanner(
  BuildContext context, {
  String? version,
  VoidCallback? onDismiss,
  bool useLatestFallback = false,
}) async {
  final l10n = L10n.of(context)!;
  final path = l10n.appAbout_versionTile_changeLogPath;
  final v = version ?? AppInfo().changelogVersion;
  final raw = await rootBundle.loadChangelog(path);
  final section = extractVersionSectionWithFallback(
    raw,
    v,
    useLatestFallback: useLatestFallback,
  );
  if (section == null || !context.mounted) return;
  ChangelogBanner.of(context).show(
    changelogContent: section,
    fullChangelog: stripChangelogPreamble(raw),
    version: v,
    onDismiss: onDismiss,
  );
}

class ChangelogBannerState extends State<ChangelogBanner> {
  final ChangelogBannerController _controller = ChangelogBannerController();

  /// The underlying controller. Exposed for widgets that need to listen
  /// directly (e.g. [_ChangelogBanner]).
  ChangelogBannerController get controller => _controller;

  /// Shows the banner for [version].
  void show({
    required String changelogContent,
    required String fullChangelog,
    required String version,
    VoidCallback? onDismiss,
  }) {
    _controller.show(
      changelogContent: changelogContent,
      fullChangelog: fullChangelog,
      version: version,
      onDismiss: onDismiss,
    );
  }

  /// Dismisses the banner.
  void dismiss() => _controller.dismiss();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ChangelogBannerScope(state: this, child: widget.child);
  }
}

class _ChangelogBannerScope extends InheritedWidget {
  final ChangelogBannerState state;

  const _ChangelogBannerScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_ChangelogBannerScope old) => false;
}

/// Controller that manages the visibility and content of the changelog banner.
///
/// Owned by [ChangelogBannerState]; widgets that need to listen for changes
/// (e.g. [_ChangelogBanner]) access it via
/// `ChangelogBanner.of(context).controller`.

class ChangelogBannerController extends ChangeNotifier {
  String _changelogContent = '';
  String _fullChangelog = '';
  String _version = '';
  VoidCallback? _onDismiss;
  bool _isShowing = false;
  int _generation = 0;

  bool get isShowing => _isShowing;

  /// The version string for the current changelog display.
  String get version => _version;

  /// The current-version section markdown content.
  String get changelogContent => _changelogContent;

  /// The full CHANGELOG.md content.
  String get fullChangelog => _fullChangelog;

  /// Unique key for the [Dismissible] widget, changes on each [show] call
  /// to force a fresh widget after swipe-dismiss.
  String get dismissibleKey => 'changelog_banner_$_generation';

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
    _generation++;
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
/// the tree; [_ChangelogBanner] manages its own expand/collapse animation.
/// Requires a [ChangelogBanner] ancestor in the widget tree.
class ChangelogBannerSliver extends StatelessWidget {
  const ChangelogBannerSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _ChangelogBanner(
        controller: ChangelogBanner.of(context).controller,
      ),
    );
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
          key: ValueKey(widget.controller.dismissibleKey),
          direction: DismissDirection.horizontal,
          resizeDuration: null,
          dismissThresholds: const {DismissDirection.horizontal: 0.4},
          onDismissed: (_) => widget.controller.dismiss(),
          child: MaterialBanner(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: const Icon(Icons.celebration_outlined),
            content: Text(
              L10n.of(
                context,
              )!.changelog_banner_title(widget.controller.version),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  widget.controller.dismiss();
                  showChangelogDialog(
                    context: context,
                    currentVersionSection: widget.controller.changelogContent,
                    fullChangelog: widget.controller.fullChangelog,
                    version: widget.controller.version,
                  );
                },
                child: Text(L10n.of(context)!.changelog_banner_view),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: widget.controller.dismiss,
                child: Text(L10n.of(context)!.changelog_banner_action),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
