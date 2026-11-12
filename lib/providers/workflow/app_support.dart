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

/// The outcome of a support dialog or a Settings support action.
///
/// [AppSupportOwner] records reminder changes for completed interactions.
/// Opening a destination does not establish that a review was submitted.
enum AppSupportResult {
  /// The GitHub Star link opened. Saving this result stops future reminders.
  githubOpened,

  /// A store review or favorite page opened. Saving this restarts cooldown.
  storeOpened,

  /// The user deferred or dismissed the dialog. Saving this restarts cooldown.
  remindLater,

  /// The user chose to permanently stop automatic reminders.
  stopReminding,

  /// Source, feedback or the donation dialog opened. History is unchanged.
  otherActionCompleted,

  /// A link or donation action failed. History is unchanged.
  actionFailed,

  /// The host was removed or the interaction cancelled. History is unchanged.
  cancelled,
}

/// Opens support links and donation options chosen from a support card.
extension AppSupportActionNavigation on AppSupportAction {
  /// Resolves the project or store URL. The host presents donation options.
  Uri? resolveUrl(AboutInfo info) => isStore
      ? storeUri
      : switch (this) {
          AppSupportAction.githubStar ||
          AppSupportAction.sourceCode => info.sourceCodeUri,
          AppSupportAction.feedback => info.issueTrackerUri,
          _ => null,
        };

  /// Opens a link or donation dialog while [isHostActive] remains true.
  Future<AppSupportResult> openDestination({
    required AboutInfo info,
    required Future<bool> Function(Uri) openUrl,
    required Future<void> Function(AboutInfo) showDonation,
    required bool Function() isHostActive,
  }) async {
    if (!isHostActive()) return AppSupportResult.cancelled;
    try {
      if (this == AppSupportAction.donate) {
        await showDonation(info);
        return isHostActive()
            ? AppSupportResult.otherActionCompleted
            : AppSupportResult.cancelled;
      }
      final target = resolveUrl(info);
      final opened = target != null && await openUrl(target);
      if (!isHostActive()) return AppSupportResult.cancelled;
      if (!opened) return AppSupportResult.actionFailed;
      if (isStore) return AppSupportResult.storeOpened;
      return this == AppSupportAction.githubStar
          ? AppSupportResult.githubOpened
          : AppSupportResult.otherActionCompleted;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportAction.openDestination',
        error: error,
        stackTrace: stackTrace,
      );
      return isHostActive()
          ? AppSupportResult.actionFailed
          : AppSupportResult.cancelled;
    }
  }
}

/// Owns the reminder for one foreground app lifetime, independently of routes.
///
/// Preserves the existing reminder dates, launch counts and dismissal keys.
/// Serializes event writes and Reset, publishes reliably saved state,
/// and keeps explicit Settings support separate from the automatic reminder guard.
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
  static const _reminderDelay = Duration(days: 7);
  static const _requiredLaunches = 10;

  SharedPreferencesAsync? _preferences;
  final DateTime Function() _now;
  final Future<AboutInfo> Function() _loadInfo;
  AppDistribution _distribution = defaultAppDistribution;
  DateTime? _nextReminderDate;
  int _launchCount = 0;
  Future<bool>? _initialization;
  Future<void>? _reminderCheck;
  bool _initialized = false;
  bool _reminderEligibilityChecked = false;
  bool _reminderSkipped = false;
  bool _reminderSaveAttempted = false;
  bool _mounted = true;
  bool _developerActionInProgress = false;
  bool _initializationComplete = false;
  bool _reminderClosed = false;
  Future<void> _pendingPreferenceWrites = Future.value();

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

  AppSupportAction get channelAction =>
      AppSupportAction.forDistribution(distribution: distribution);

  void setDistribution(AppDistribution value) {
    if (!mounted || _distribution == value) return;
    _distribution = value;
    notifyListeners();
  }

  Future<bool> _queuePreferenceWrite(Future<bool> Function() action) {
    final result = _pendingPreferenceWrites.then<bool>(
      (_) => !mounted ? false : action(),
    );
    _pendingPreferenceWrites = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  /// Whether a developer reset or preview is already running.
  bool get developerActionInProgress => _developerActionInProgress;

  /// Whether this session can show a reminder given the current synchronization state.
  ///
  /// Unconfirmed WebDAV setup may still open its own dialog asynchronously.
  /// Reminder timing is checked separately by [checkReminderEligibility].
  bool canShowReminderWithSync({
    required bool enabled,
    required AppSyncServer? server,
    required bool processing,
  }) =>
      mounted &&
      !_reminderSkipped &&
      !processing &&
      !(enabled && server is AppWebDavSyncServer && !server.configed);

  Future<AboutInfo?> _loadDialogInfo() async {
    final info = await _loadInfo();
    if (info.sourceCodeUri == null && channelAction.resolveUrl(info) == null) {
      appLog.load.info('AppSupportOwner.invalidTarget');
      return null;
    }
    return info;
  }

  /// Clears dismissal and cooldown so the next launch can show the reminder.
  Future<bool> resetReminderForNextLaunch() async {
    if (!mounted || _developerActionInProgress) return false;
    _developerActionInProgress = true;
    skipReminderForSession();
    try {
      if (!await init() || !mounted) return false;
      return await _queuePreferenceWrite(
        () => _saveReminderHistory(
          DateTime.utc(1970),
          _requiredLaunches - 1,
          false,
        ),
      );
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.resetReminderForNextLaunch',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _developerActionInProgress = false;
    }
  }

  /// Shows the production dialog for Developer preview, preserving history.
  Future<bool> previewDialog({
    required bool Function() canShowDialog,
    required Future<AppSupportResult> Function(AboutInfo info)
    showSupportDialog,
  }) async {
    if (!mounted || _developerActionInProgress) return false;
    _developerActionInProgress = true;
    skipReminderForSession();
    try {
      final info = await _loadDialogInfo();
      if (!mounted || info == null || !canShowDialog()) return false;
      final result = await showSupportDialog(info);
      return mounted && result != AppSupportResult.cancelled;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.previewDialog',
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
          ? _now().add(_reminderDelay)
          : DateTime.fromMillisecondsSinceEpoch(storedDate, isUtc: true);
      final launches = (values[_launchesKey] as int? ?? 0) + 1;
      final closed = values[_closedKey] as bool? ?? false;
      if (!await _saveReminderHistory(minimumDate, launches, closed)) {
        return false;
      }
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

  /// Skips the automatic reminder for this foreground session.
  ///
  /// This changes only the current session's state, without saving preferences.
  void skipReminderForSession() => _reminderSkipped = true;

  /// Shows the automatic reminder once when timing and UI safety permit it.
  ///
  /// UI supplies live route/lifecycle checks and presentation. Eligibility is
  /// checked before I/O; safety is checked again after the asynchronous load.
  Future<void> showReminderIfEligible({
    required bool Function() canShowDialog,
    required Future<AppSupportResult> Function(AboutInfo info)
    showSupportDialog,
    VoidCallback? onReminderSaveFailed,
  }) => _reminderCheck ??= _showReminderIfEligible(
    canShowDialog,
    showSupportDialog,
    onReminderSaveFailed,
  );

  Future<void> _showReminderIfEligible(
    bool Function() canShowDialog,
    Future<AppSupportResult> Function(AboutInfo info) showSupportDialog,
    VoidCallback? onReminderSaveFailed,
  ) async {
    try {
      if (!await init()) return;
      if (!checkReminderEligibility(canShowDialog: canShowDialog())) return;
      final info = await _loadDialogInfo();
      if (info == null) return;
      if (_reminderSkipped || !canShowDialog()) return;
      final result = await showSupportDialog(info);
      final saved = await recordReminderResult(result);
      if (mounted &&
          !saved &&
          (result == AppSupportResult.githubOpened ||
              result == AppSupportResult.storeOpened ||
              result == AppSupportResult.remindLater ||
              result == AppSupportResult.stopReminding)) {
        onReminderSaveFailed?.call();
      }
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.showReminderIfEligible',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Checks reminder eligibility and marks this session's check as complete.
  ///
  /// Later calls return false, including when the first check was ineligible.
  bool checkReminderEligibility({required bool canShowDialog}) {
    if (_reminderEligibilityChecked) return false;
    _reminderEligibilityChecked = true;
    return !_reminderSkipped &&
        canShowDialog &&
        _initialized &&
        !_reminderClosed &&
        _launchCount >= _requiredLaunches &&
        _now().isAfter(_nextReminderDate!);
  }

  /// Saves the automatic reminder's result at most once per session.
  ///
  /// A failed save counts as the session's attempt and is not retried here.
  Future<bool> recordReminderResult(AppSupportResult result) async {
    if (!mounted || !_initialized || _reminderSaveAttempted) return false;
    if (!_changesReminderHistory(result)) return false;
    _reminderSaveAttempted = true;
    return _saveReminderResult(result);
  }

  /// Saves a Settings GitHub or store result, skipping this session's reminder.
  ///
  /// Each explicit Settings action can save its result independently.
  Future<bool> recordSettingsSupportResult([
    AppSupportResult result = AppSupportResult.githubOpened,
  ]) async {
    skipReminderForSession();
    if (!mounted || !_initialized) return false;
    if (result != AppSupportResult.githubOpened &&
        result != AppSupportResult.storeOpened) {
      return false;
    }
    return _saveReminderResult(result);
  }

  bool _changesReminderHistory(AppSupportResult result) =>
      result == AppSupportResult.githubOpened ||
      result == AppSupportResult.storeOpened ||
      result == AppSupportResult.remindLater ||
      result == AppSupportResult.stopReminding;

  Future<bool> _saveReminderResult(AppSupportResult result) =>
      _queuePreferenceWrite(() async {
        try {
          if (_reminderClosed && result == AppSupportResult.githubOpened) {
            return true;
          }
          final restartCooldown =
              result == AppSupportResult.storeOpened ||
              result == AppSupportResult.remindLater;
          return await _saveReminderHistory(
            restartCooldown ? _now().add(_reminderDelay) : _nextReminderDate!,
            restartCooldown ? _launchCount - _requiredLaunches : _launchCount,
            _reminderClosed ||
                result == AppSupportResult.githubOpened ||
                result == AppSupportResult.stopReminding,
          );
        } catch (error, stackTrace) {
          appLog.load.warn(
            'AppSupportOwner.saveReminderResult',
            error: error,
            stackTrace: stackTrace,
          );
          return false;
        }
      });

  /// Publishes state only after all three legacy keys have been saved.
  Future<bool> _saveReminderHistory(
    DateTime minimumDate,
    int launches,
    bool closed,
  ) async {
    await _storage.setInt(_minimumDateKey, minimumDate.millisecondsSinceEpoch);
    if (!mounted) return false;
    await _storage.setInt(_launchesKey, launches);
    if (!mounted) return false;
    await _storage.setBool(_closedKey, closed);
    if (!mounted) return false;
    _nextReminderDate = minimumDate;
    _launchCount = launches;
    _reminderClosed = closed;
    if (_initialized) notifyListeners();
    return true;
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    skipReminderForSession();
    super.dispose();
  }
}
