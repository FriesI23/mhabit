// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';
import 'package:provider/provider.dart';

import '../../../common/utils.dart';
import '../../../l10n/localizations.dart';
import '../../../logging/helper.dart';
import '../../../providers/workflow/app_support.dart';

/// Shows a standard dialog with bottom actions, without consuming reminder events.
///
/// Normal pops count as later; route removal and navigator destruction do not.
/// An optional [controller] belongs to the host and can abort its own route.
/// [platformName] only labels the destination; [target] determines what opens.
Future<AppSupportPromptResult> showAppSupportDialog({
  required BuildContext context,
  required Uri target,
  String platformName = 'GitHub',
  Future<bool> Function(Uri)? openUrl,
  AppSupportDialogController? controller,
}) async {
  final state = controller ?? AppSupportDialogController();
  if (state._finished) return AppSupportPromptResult.aborted;
  try {
    final result = await showAdaptiveModalDialog<AppSupportPromptResult>(
      context: context,
      barrierDismissible: true,
      routeSettings: const RouteSettings(name: 'app-support'),
      builder: (context) {
        state._route = ModalRoute.of<AppSupportPromptResult>(context);
        return ChangeNotifierProvider<AppSupportDialogController>.value(
          value: state,
          child: _AppSupportDialog(
            target: target,
            platformName: platformName,
            openUrl: openUrl ?? launchExternalUrl,
          ),
        );
      },
    );
    state._finished = true;
    if (state._aborted) return AppSupportPromptResult.aborted;
    return result ??
        (state._popped
            ? AppSupportPromptResult.later
            : AppSupportPromptResult.aborted);
  } finally {
    if (controller == null) state.dispose();
  }
}

/// Provider state for one dialog interaction, including host invalidation.
///
/// A host that supplies this controller owns disposal. It must [abort] before
/// disposal if its dialog may still be visible. A controller cannot be reused.
class AppSupportDialogController extends ChangeNotifier {
  bool _opening = false;
  bool _failed = false;
  bool _popped = false;
  bool _finished = false;
  bool _aborted = false;
  ModalRoute<AppSupportPromptResult>? _route;

  bool get opening => _opening;
  bool get failed => _failed;

  /// Removes only this dialog, even if another route has since appeared above it.
  void abort() {
    if (_finished) return;
    _aborted = true;
    _finished = true;
    // The host may be disposed while the tree is locked. Route removal must
    // wait until after this frame, and also request a frame when none is pending.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = _route;
      final navigator = route?.navigator;
      if (route != null && route.isActive && navigator?.mounted == true) {
        navigator!.removeRoute(route);
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  void _finish(AppSupportPromptResult result) {
    if (_finished) return;
    _finished = true;
    _route?.navigator?.pop(result);
  }

  Future<void> _open(Uri target, Future<bool> Function(Uri) openUrl) async {
    if (_opening || _finished) return;
    _opening = true;
    _failed = false;
    notifyListeners();
    var opened = false;
    try {
      opened = await openUrl(target);
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportDialog.open',
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (_finished || _route?.isActive != true) return;
    if (opened) {
      _finish(AppSupportPromptResult.githubOpened);
    } else {
      _opening = false;
      _failed = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _finished = true;
    super.dispose();
  }
}

class _AppSupportDialog extends StatelessWidget {
  const _AppSupportDialog({
    required this.target,
    required this.platformName,
    required this.openUrl,
  });

  final Uri target;
  final String platformName;
  final Future<bool> Function(Uri) openUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final state = context.read<AppSupportDialogController>();
    final (opening, failed) = context
        .select<AppSupportDialogController, (bool, bool)>(
          (value) => (value.opening, value.failed),
        );
    return PopScope<AppSupportPromptResult>(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          state._popped = true;
          state._finished = true;
        }
      },
      child: AdaptiveDialog(
        title: Text(l10n.appSupport_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.appSupport_message),
            if (failed)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(l10n.appSupport_linkFailed),
                ),
              ),
          ],
        ),
        actions: [
          AdaptiveDialogAction(
            label: l10n.appSupport_never,
            enabled: !opening,
            isDestructiveAction: true,
            onPressed: () => state._finish(AppSupportPromptResult.never),
          ),
          AdaptiveDialogAction(
            label: l10n.appSupport_later,
            enabled: !opening,
            onPressed: () => state._finish(AppSupportPromptResult.later),
          ),
          AdaptiveDialogAction(
            label: l10n.appSupport_open(platformName),
            enabled: !opening,
            isDefaultAction: true,
            onPressed: () => state._open(target, openUrl),
          ),
        ],
      ),
    );
  }
}

/// Hosts an automatic support prompt at a caller-selected location.
///
/// The owner holds eligibility and the once-per-session guard. The caller
/// provides [AppSupportOwner] with ChangeNotifierProvider, chooses when to mount
/// this widget and supplies live presentation safety.
class AppSupportPrompt extends StatefulWidget {
  const AppSupportPrompt({
    super.key,
    required this.canPresent,
    required this.child,
    this.showPrompt = showAppSupportDialog,
  });

  /// Reads current UI safety, including immediately after asynchronous work.
  /// Callers subscribe to reactive dependencies with Provider so changes also
  /// rebuild this host and permanently cancel this startup's opportunity.
  final bool Function(BuildContext context) canPresent;
  final Widget child;
  final Future<AppSupportPromptResult> Function({
    required BuildContext context,
    required Uri target,
    AppSupportDialogController? controller,
  })
  showPrompt;

  @override
  State<AppSupportPrompt> createState() => _AppSupportPromptState();
}

class _AppSupportPromptState extends State<AppSupportPrompt> {
  late final AppSupportOwner _owner;
  late final AppLifecycleListener _lifecycle;
  final _dialog = AppSupportDialogController();
  bool _checkScheduled = false;
  bool _firstFrameComplete = false;
  late bool _hasEnteredForeground;

  @override
  void initState() {
    super.initState();
    _owner = context.read<AppSupportOwner>();
    _hasEnteredForeground =
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          if (!_hasEnteredForeground) {
            _hasEnteredForeground = true;
            _scheduleCheck();
          }
        } else if (_hasEnteredForeground) {
          _owner.skipPrompt();
        }
      },
    );
    HardwareKeyboard.instance.addHandler(_onKey);
    _owner.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstFrameComplete = true;
    });
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) _owner.skipPrompt();
    return false;
  }

  void _scheduleCheck() {
    if (!mounted ||
        !_owner.initialized ||
        !_hasEnteredForeground ||
        _checkScheduled ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    WidgetsBinding.instance.scheduleFrame();
  }

  Future<void> _check() => _owner.checkPrompt(
    canPresent: () =>
        mounted &&
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed &&
        widget.canPresent(context),
    showPrompt: (target) async {
      if (!mounted) return AppSupportPromptResult.aborted;
      final result = await widget.showPrompt(
        context: context,
        target: target,
        controller: _dialog,
      );
      return mounted ? result : AppSupportPromptResult.aborted;
    },
  );

  @override
  void dispose() {
    _owner.skipPrompt();
    _dialog.abort();
    _dialog.dispose();
    _lifecycle.dispose();
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.select<AppSupportOwner, bool>(
      (owner) => owner.initialized,
    );
    // Provider rebuilds this host when initialization or caller safety changes.
    // Cancelling is sticky; becoming safe again never queues another prompt.
    // Initial navigators are not attached until the first build completes.
    if (_firstFrameComplete &&
        _hasEnteredForeground &&
        !widget.canPresent(context)) {
      _owner.skipPrompt();
    }
    _scheduleCheck();
    return Listener(
      onPointerDown: (_) => _owner.skipPrompt(),
      onPointerSignal: (_) => _owner.skipPrompt(),
      child: widget.child,
    );
  }
}
