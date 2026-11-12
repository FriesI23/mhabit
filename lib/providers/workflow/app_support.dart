// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/async.dart';
import '../../common/distribution.dart';
import '../../logging/helper.dart';
import '../../models/app_support.dart';
import '../../models/app_sync_server.dart';
import '../../utils/app_clock.dart';
import '../support/about_info.dart';
import '../support/commons.dart';

export '../../models/app_support.dart' show AppSupportAction;

/// A completed interaction, distinct from a route being removed or destroyed.
///
/// Store links update the cooldown; GitHub support and never close reminders.
/// Opening a destination does not establish that a review was submitted.
enum AppSupportPromptResult {
  supportOpened,
  storeOpened,
  later,
  never,
  auxiliaryAction,
  actionFailed,
  aborted,
}

/// Executes a resolved selection; channel routing lives in the action model.
extension AppSupportActionExecution on AppSupportAction {
  Uri? destination(AboutInfo info) => isStore
      ? storeUri
      : switch (this) {
          AppSupportAction.support ||
          AppSupportAction.sourceCode => info.sourceCodeUri,
          AppSupportAction.feedback => info.issueTrackerUri,
          _ => null,
        };

  /// Executes this action while the caller owns the host lifetime.
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
      final target = destination(info);
      final opened = target != null && await openUrl(target);
      if (!isAlive()) return AppSupportPromptResult.aborted;
      if (!opened) return AppSupportPromptResult.actionFailed;
      if (isStore) return AppSupportPromptResult.storeOpened;
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
/// Preserves the existing reminder dates, launch counts and dismissal keys.
/// Serializes event writes and Reset, publishes reliably saved state,
/// and keeps explicit Settings support separate from the startup prompt guard.
class AppSupportOwner extends ChangeNotifier
    implements AsyncInitialization, ProviderMounted {
  AppSupportOwner({
    this._preferences,
    DateTime Function()? now,
    Future<AboutInfo> Function()? loadInfo,
  }) : _now = now ?? AppClock().now,
       _loadInfo = loadInfo ?? loadAboutInfo;

  static const _minimumDateKey = 'appSupport_minimumDate';
  static const _launchesKey = 'appSupport_launches';
  static const _closedKey = 'appSupport_doNotOpenAgain';
  static const _days = Duration(days: 7);
  static const _launchThreshold = 10;

  SharedPreferencesAsync? _preferences;
  final DateTime Function() _now;
  final Future<AboutInfo> Function() _loadInfo;
  AppDistribution _distribution = defaultAppDistribution;
  DateTime? _minimumDate;
  int _launches = 0;
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

  SharedPreferencesAsync get _storage =>
      _preferences ??= SharedPreferencesAsync();

  @override
  bool get mounted => _mounted;

  /// Whether initialization succeeded. Provider subscribers can now check UI safety.
  bool get initialized => _initialized;

  /// Includes failed initialization, so persistent content can still be shown.
  bool get initializationComplete => _initializationComplete;

  /// Last reliably saved permanent dismissal state.
  bool get reminderClosed => _reminderClosed;

  /// The current process's support channel, initialized from the build value.
  AppDistribution get distribution => _distribution;

  AppSupportAction get supportAction =>
      AppSupportAction.supportFor(distribution: distribution);

  void setDistribution(AppDistribution value) {
    if (!mounted || _distribution == value) return;
    _distribution = value;
    notifyListeners();
  }

  Future<bool> _serialize(Future<bool> Function() action) {
    final result = _writes.then<bool>((_) => !mounted ? false : action());
    _writes = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  /// Whether a developer reset or preview is already running.
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
    if (info.sourceCodeUri == null && supportAction.destination(info) == null) {
      appLog.load.info('AppSupportOwner.invalidTarget');
      return null;
    }
    return info;
  }

  /// Arms the next full launch without prompting in this session.
  Future<bool> resetForNextLaunch() async {
    if (!mounted || _developerActionInProgress) return false;
    _developerActionInProgress = true;
    skipPrompt();
    try {
      if (!await init() || !mounted) return false;
      return await _serialize(
        () => _persist(DateTime.utc(1970), _launchThreshold - 1, false),
      );
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.resetForNextLaunch',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _developerActionInProgress = false;
    }
  }

  /// Previews the production dialog without initializing or changing history.
  Future<bool> previewPrompt({
    required bool Function() canPresent,
    required Future<AppSupportPromptResult> Function(AboutInfo info) showPrompt,
  }) async {
    if (!mounted || _developerActionInProgress) return false;
    _developerActionInProgress = true;
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
    }
  }

  /// Shares success or failure and counts this foreground launch only once.
  @override
  Future<bool> init() => _initialization ??= _init();

  Future<bool> _init() async {
    if (!mounted) return false;
    try {
      final values = await _storage.getAll(
        allowList: {_minimumDateKey, _launchesKey, _closedKey},
      );
      if (!mounted) return false;
      final storedDate = values[_minimumDateKey] as int?;
      final minimumDate = storedDate == null
          ? _now().add(_days)
          : DateTime.fromMillisecondsSinceEpoch(storedDate, isUtc: true);
      final launches = (values[_launchesKey] as int? ?? 0) + 1;
      final closed = values[_closedKey] as bool? ?? false;
      if (!await _persist(minimumDate, launches, closed)) return false;
      if (!mounted) return false;
      _initialized = true;
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
              result == AppSupportPromptResult.storeOpened ||
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
        !_reminderClosed &&
        _launches >= _launchThreshold &&
        _now().isAfter(_minimumDate!);
  }

  /// Persists one automatic result. A failed save is not retried automatically.
  Future<bool> consume(AppSupportPromptResult result) async {
    if (!mounted || !_initialized || _consumed) return false;
    if (!_isReminderResult(result)) return false;
    _consumed = true;
    return _saveResult(result);
  }

  /// Records a Settings link action independently of the startup result guard.
  Future<bool> recordSupportOpened([
    AppSupportPromptResult result = AppSupportPromptResult.supportOpened,
  ]) async {
    skipPrompt();
    if (!mounted || !_initialized) return false;
    if (result != AppSupportPromptResult.supportOpened &&
        result != AppSupportPromptResult.storeOpened) {
      return false;
    }
    return _saveResult(result);
  }

  bool _isReminderResult(AppSupportPromptResult result) =>
      result == AppSupportPromptResult.supportOpened ||
      result == AppSupportPromptResult.storeOpened ||
      result == AppSupportPromptResult.later ||
      result == AppSupportPromptResult.never;

  Future<bool> _saveResult(AppSupportPromptResult result) => _serialize(
    () async {
      try {
        if (_reminderClosed && result == AppSupportPromptResult.supportOpened) {
          return true;
        }
        final cooldown =
            result == AppSupportPromptResult.storeOpened ||
            result == AppSupportPromptResult.later;
        return await _persist(
          cooldown ? _now().add(_days) : _minimumDate!,
          cooldown ? _launches - _launchThreshold : _launches,
          _reminderClosed ||
              result == AppSupportPromptResult.supportOpened ||
              result == AppSupportPromptResult.never,
        );
      } catch (error, stackTrace) {
        appLog.load.warn(
          'AppSupportOwner.consume',
          error: error,
          stackTrace: stackTrace,
        );
        return false;
      }
    },
  );

  /// Publishes state only after all three legacy keys have been saved.
  Future<bool> _persist(DateTime minimumDate, int launches, bool closed) async {
    await _storage.setInt(_minimumDateKey, minimumDate.millisecondsSinceEpoch);
    if (!mounted) return false;
    await _storage.setInt(_launchesKey, launches);
    if (!mounted) return false;
    await _storage.setBool(_closedKey, closed);
    if (!mounted) return false;
    _minimumDate = minimumDate;
    _launches = launches;
    _reminderClosed = closed;
    if (_initialized) notifyListeners();
    return true;
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    skipPrompt();
    super.dispose();
  }
}
