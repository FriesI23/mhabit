// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/foundation.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../common/async.dart';
import '../../logging/helper.dart';
import '../../models/app_sync_server.dart';
import '../support/about_info.dart';
import '../support/commons.dart';

/// A completed interaction, distinct from a route being removed or destroyed.
///
/// Only supportOpened, later and never map to package reminder events. Opening
/// an auxiliary destination, failure and aborted work do not consume history.
enum AppSupportPromptResult {
  supportOpened,
  later,
  never,
  auxiliaryAction,
  actionFailed,
  aborted,
}

/// Business selections, independent of the route hosting the cards.
///
/// Card widgets report these values. Hosts own duplicate suppression and decide
/// whether to close first; this enum executes links or the shared donation UI.
enum AppSupportAction {
  support,
  sourceCode,
  feedback,
  donate;

  /// Executes this action while the caller owns locking and host lifetime.
  Future<AppSupportPromptResult> execute({
    required AboutInfo info,
    required Future<bool> Function(Uri) openUrl,
    required Future<void> Function(AboutInfo) showDonation,
    required bool Function() isAlive,
  }) async {
    if (!isAlive()) return AppSupportPromptResult.aborted;
    try {
      if (this == AppSupportAction.donate) {
        await showDonation(info);
        return isAlive()
            ? AppSupportPromptResult.auxiliaryAction
            : AppSupportPromptResult.aborted;
      }
      final destination = switch (this) {
        AppSupportAction.support ||
        AppSupportAction.sourceCode => info.sourceCodeUri,
        AppSupportAction.feedback => info.issueTrackerUri,
        AppSupportAction.donate => null,
      };
      final opened = destination != null && await openUrl(destination);
      if (!isAlive()) return AppSupportPromptResult.aborted;
      if (!opened) return AppSupportPromptResult.actionFailed;
      return this == AppSupportAction.support
          ? AppSupportPromptResult.supportOpened
          : AppSupportPromptResult.auxiliaryAction;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportAction.execute',
        error: error,
        stackTrace: stackTrace,
      );
      return isAlive()
          ? AppSupportPromptResult.actionFailed
          : AppSupportPromptResult.aborted;
    }
  }
}

/// Owns the reminder for one foreground app lifetime, independently of routes.
///
/// Only the package owns dates, launch counts and persisted dismissal state.
/// This owner serializes event writes and Reset, publishes reliably saved state,
/// and keeps explicit Settings support separate from the startup prompt guard.
class AppSupportOwner extends ChangeNotifier
    implements AsyncInitialization, ProviderMounted {
  AppSupportOwner({RateMyApp? reminder, Future<AboutInfo> Function()? loadInfo})
    : _loadInfo = loadInfo ?? loadAboutInfo,
      _reminder =
          reminder ??
          RateMyApp(
            preferencesPrefix: 'appSupport_',
            minDays: 7,
            minLaunches: 10,
            remindDays: 7,
            remindLaunches: 10,
          );

  final RateMyApp _reminder;
  final Future<AboutInfo> Function() _loadInfo;
  Future<bool>? _initialization;
  Future<void>? _promptCheck;
  bool _initialized = false;
  bool _checked = false;
  bool _blocked = false;
  bool _consumed = false;
  bool _mounted = true;
  bool _developerActionInProgress = false;
  bool _initializationComplete = false;
  bool _reminderClosed = false;
  Future<void> _writes = Future.value();

  @override
  bool get mounted => _mounted;

  /// Whether initialization succeeded. Provider subscribers can now check UI safety.
  bool get initialized => _initialized;

  /// Includes failed initialization, so persistent content can still be shown.
  bool get initializationComplete => _initializationComplete;

  /// Last reliably saved package state; rate and never share this condition.
  bool get reminderClosed => _reminderClosed;

  bool _readClosed() => _reminder.conditions
      .whereType<DoNotOpenAgainCondition>()
      .any((condition) => condition.doNotOpenAgain);

  Future<bool> _serialize(Future<bool> Function() action) {
    final result = _writes.then<bool>((_) => !mounted ? false : action());
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  /// Serializes developer reset and preview actions across settings rebuilds.
  bool get developerActionInProgress => _developerActionInProgress;

  /// Whether this session can prompt given the current synchronization state.
  ///
  /// Unconfirmed WebDAV setup may still open its own dialog asynchronously.
  /// Reminder eligibility is checked separately by [claimPrompt].
  bool canPromptWithSync({
    required bool enabled,
    required AppSyncServer? server,
    required bool processing,
  }) =>
      mounted &&
      !_blocked &&
      !processing &&
      !(enabled && server is AppWebDavSyncServer && !server.configed);

  Future<AboutInfo?> _loadPromptInfo() async {
    final info = await _loadInfo();
    if (info.sourceCodeUri == null) {
      appLog.load.info('AppSupportOwner.invalidTarget');
      return null;
    }
    return info;
  }

  /// Arms package-owned eligibility for the next full launch, without prompting now.
  ///
  /// Developer tooling only: unlike RateMyApp.reset, this also bypasses the
  /// initial day/launch thresholds. Normal startup safety checks still apply.
  Future<bool> resetForNextLaunch() async {
    if (!mounted || _developerActionInProgress) return false;
    _developerActionInProgress = true;
    notifyListeners();
    skipPrompt();
    try {
      if (!await init() || !mounted) return false;
      return await _serialize(() async {
        for (final condition in _reminder.conditions) {
          switch (condition) {
            case MinimumDaysCondition():
              condition.minimumDate = DateTime.utc(1970);
            case MinimumAppLaunchesCondition():
              condition.launches = condition.minLaunches - 1;
            case DoNotOpenAgainCondition():
              condition.doNotOpenAgain = false;
          }
        }
        await _reminder.save();
        if (mounted) _reminderClosed = _readClosed();
        return true;
      });
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.resetForNextLaunch',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _developerActionInProgress = false;
      if (mounted) notifyListeners();
    }
  }

  /// Previews the production dialog without claiming eligibility or saving an event.
  Future<bool> previewPrompt({
    required bool Function() canPresent,
    required Future<AppSupportPromptResult> Function(AboutInfo info) showPrompt,
  }) async {
    if (!mounted || _developerActionInProgress) return false;
    _developerActionInProgress = true;
    notifyListeners();
    skipPrompt();
    try {
      final info = await _loadPromptInfo();
      if (!mounted || info == null || !canPresent()) return false;
      final result = await showPrompt(info);
      return mounted && result != AppSupportPromptResult.aborted;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.previewPrompt',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _developerActionInProgress = false;
      if (mounted) notifyListeners();
    }
  }

  /// Shares success or failure; a failed initialization is not retried.
  @override
  Future<bool> init() => _initialization ??= _init();

  Future<bool> _init() async {
    if (!mounted) return false;
    try {
      await _reminder.init();
      if (!mounted) return false;
      _initialized = true;
      _reminderClosed = _readClosed();
      return true;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.init',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _initializationComplete = true;
      if (mounted) notifyListeners();
    }
  }

  /// Cancels automatic prompting for this foreground session without saving a preference.
  void skipPrompt() => _blocked = true;

  /// Checks once, loading project configuration only for an eligible session.
  ///
  /// UI supplies live route/lifecycle checks and presentation. Eligibility is
  /// checked before I/O; safety is checked again after the asynchronous load.
  Future<void> checkPrompt({
    required bool Function() canPresent,
    required Future<AppSupportPromptResult> Function(AboutInfo info) showPrompt,
    VoidCallback? onSaveFailed,
  }) => _promptCheck ??= _checkPrompt(canPresent, showPrompt, onSaveFailed);

  Future<void> _checkPrompt(
    bool Function() canPresent,
    Future<AppSupportPromptResult> Function(AboutInfo info) showPrompt,
    VoidCallback? onSaveFailed,
  ) async {
    try {
      if (!await init()) return;
      if (!claimPrompt(canPresent: canPresent())) return;
      final info = await _loadPromptInfo();
      if (info == null) return;
      if (_blocked || !canPresent()) return;
      final result = await showPrompt(info);
      final saved = await consume(result);
      if (mounted &&
          !saved &&
          (result == AppSupportPromptResult.supportOpened ||
              result == AppSupportPromptResult.later ||
              result == AppSupportPromptResult.never)) {
        onSaveFailed?.call();
      }
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.checkPrompt',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Claims the only automatic opportunity, even when eligibility or safety fails.
  bool claimPrompt({required bool canPresent}) {
    if (_checked) return false;
    _checked = true;
    return !_blocked &&
        canPresent &&
        _initialized &&
        _reminder.shouldOpenDialog;
  }

  /// Persists one result. False means no preference was reliably saved.
  Future<bool> consume(AppSupportPromptResult result) async {
    if (!mounted || !_initialized || _consumed) return false;
    final event = switch (result) {
      AppSupportPromptResult.supportOpened =>
        RateMyAppEventType.rateButtonPressed,
      AppSupportPromptResult.later => RateMyAppEventType.laterButtonPressed,
      AppSupportPromptResult.never => RateMyAppEventType.noButtonPressed,
      AppSupportPromptResult.auxiliaryAction ||
      AppSupportPromptResult.actionFailed ||
      AppSupportPromptResult.aborted => null,
    };
    if (event == null) return false;
    _consumed = true;
    return _saveEvent(event);
  }

  /// Records an explicit Settings action, independently of the startup guard.
  Future<bool> recordSupportOpened() async {
    skipPrompt();
    if (!mounted || !_initialized) return false;
    return _saveEvent(RateMyAppEventType.rateButtonPressed);
  }

  Future<bool> _saveEvent(RateMyAppEventType event) => _serialize(() async {
    try {
      if (_reminderClosed && event == RateMyAppEventType.rateButtonPressed) {
        return true;
      }
      await _reminder.callEvent(event);
      if (mounted) {
        _reminderClosed = _readClosed();
        notifyListeners();
      }
      return true;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.consume',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  });

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    skipPrompt();
    super.dispose();
  }
}
