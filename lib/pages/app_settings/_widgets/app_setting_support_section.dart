// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/material.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/app_info.dart';
import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../providers/support/about_info.dart';
import '../../../providers/support/commons.dart';
import '../../../providers/workflow/app_support.dart';
import '../../common/widgets.dart';

/// Persistent Settings card; only explicit successful support records rate.
///
/// Observes an existing [AppSupportOwner] without initializing it or checking
/// startup eligibility. The card remains visible after reminder preferences
/// change. This host stays mounted while actions run and presents retryable
/// errors here.
class AppSettingSupportSection extends StatefulWidget {
  const AppSettingSupportSection({
    super.key,
    this.loadInfo = loadAboutInfo,
    this.openUrl = launchExternalUrl,
    this.showDonation,
    this.hideDonate,
  });

  final Future<AboutInfo> Function() loadInfo;
  final Future<bool> Function(Uri) openUrl;
  final Future<void> Function(AboutInfo)? showDonation;
  final bool? hideDonate;

  @override
  State<AppSettingSupportSection> createState() =>
      _AppSettingSupportSectionState();
}

class _AppSettingSupportSectionState extends State<AppSettingSupportSection> {
  late final Future<AboutInfo> _info;
  final _actions = _AppSettingSupportController();

  @override
  void initState() {
    super.initState();
    _info = widget.loadInfo();
  }

  @override
  void dispose() {
    _actions.dispose();
    super.dispose();
  }

  Future<void> _select(AppSupportAction action, AppSupportContent content) =>
      _actions.select(
        action: action,
        info: content.info,
        owner: context.read<AppSupportOwner>(),
        openUrl: widget.openUrl,
        showDonation:
            widget.showDonation ?? (_) => content.showDonation(context),
      );

  Widget _buildSection(
    BuildContext context,
    AsyncSnapshot<AboutInfo> snapshot,
  ) {
    if (!snapshot.hasData) return const SizedBox.shrink();
    final content = AppSupportContent(
      info: snapshot.requireData,
      hideDonate: widget.hideDonate ?? AppInfo().shouldHideDonate(),
    );
    final l10n = L10n.of(context)!;
    if (!content.hasCards(l10n.appAbout_donateTile_ways)) {
      return const SizedBox.shrink();
    }
    return AdaptiveListSection(
      key: const ValueKey('settings-support'),
      children: [
        _AppSettingSupportContent(
          content: content,
          actions: _actions,
          onSelected: (action) => _select(action, content),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final complete = context.select<AppSupportOwner, bool>(
      (owner) => owner.initializationComplete,
    );
    return FutureBuilder<AboutInfo>(
      future: _info,
      builder: (context, snapshot) =>
          complete ? _buildSection(context, snapshot) : const SizedBox.shrink(),
    );
  }
}

class _AppSettingSupportContent extends StatelessWidget {
  const _AppSettingSupportContent({
    required this.content,
    required this.actions,
    required this.onSelected,
  });

  final AppSupportContent content;
  final _AppSettingSupportController actions;
  final ValueChanged<AppSupportAction> onSelected;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: actions,
    builder: (context, _) {
      final l10n = L10n.of(context)!;
      final errorText = switch (actions.failure) {
        _AppSettingSupportFailure.open => l10n.appSupport_linkFailed,
        _AppSettingSupportFailure.save => l10n.appSupport_saveFailed,
        null => null,
      };
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppSupportCarousel(
              content: content,
              active: !actions.busy,
              enabled: !actions.busy,
              onSelected: onSelected,
            ),
            if (errorText != null)
              Semantics(liveRegion: true, child: Text(errorText)),
          ],
        ),
      );
    },
  );
}

enum _AppSettingSupportFailure { open, save }

/// Settings action state; the widget owns presentation only.
class _AppSettingSupportController extends ChangeNotifier
    implements ProviderMounted {
  bool _mounted = true;
  bool _busy = false;
  _AppSettingSupportFailure? _failure;

  @override
  bool get mounted => _mounted;

  bool get busy => _busy;
  _AppSettingSupportFailure? get failure => _failure;

  Future<void> select({
    required AppSupportAction action,
    required AboutInfo info,
    required AppSupportOwner owner,
    required Future<bool> Function(Uri) openUrl,
    required Future<void> Function(AboutInfo) showDonation,
  }) async {
    if (_busy || !mounted || !owner.mounted) return;
    _busy = true;
    _failure = null;
    notifyListeners();
    try {
      final result = await action.execute(
        info: info,
        openUrl: openUrl,
        showDonation: showDonation,
        isAlive: () => mounted && owner.mounted,
      );
      if (!mounted || !owner.mounted) return;
      if (result == AppSupportPromptResult.supportOpened) {
        final saved = await owner.recordSupportOpened();
        if (!mounted || !owner.mounted) return;
        if (!saved) _failure = _AppSettingSupportFailure.save;
      } else if (result == AppSupportPromptResult.actionFailed) {
        _failure = _AppSettingSupportFailure.open;
      }
    } finally {
      _busy = false;
      if (mounted) notifyListeners();
    }
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    super.dispose();
  }
}
