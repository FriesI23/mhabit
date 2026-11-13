// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/foundation.dart';

import '../../common/async.dart';
import '../../common/distribution.dart';
import '../../logging/helper.dart';
import '../../models/app_support.dart';
import '../../models/app_sync_server.dart';
import '../../storage/profile/handlers.dart';
import '../../storage/profile_provider.dart';
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
/// Stores reminder dates, launch counts and dismissal in the profile preferences.
/// Serializes event writes and Reset, reads history from the profile,
/// and keeps explicit Settings support separate from the automatic reminder guard.
class AppSupportOwner extends ChangeNotifier
    with ProfileHandlerLoadedMixin
    implements AsyncInitialization, ProviderMounted {
  AppSupportOwner({
    ProfileViewModel? profile,
    DateTime Function()? now,
    Future<AboutInfo> Function()? loadInfo,
  }) : _now = now ?? AppClock().now,
       _loadInfo = loadInfo ?? loadAboutInfo {
    if (profile != null) updateProfile(profile);
  }

  static const _reminderDelay = Duration(days: 7);
  static const _requiredLaunches = 10;

  AppSupportReminderProfileHandler? _reminder;
  final DateTime Function() _now;
  final Future<AboutInfo> Function() _loadInfo;
  AppDistribution _distribution = defaultAppDistribution;
  Future<bool>? _initFuture;
  Future<void>? _reminderCheck;
  bool _inited = false;
  bool _reminderEligibilityChecked = false;
  bool _reminderSkipped = false;
  bool _reminderSaveAttempted = false;
  bool _mounted = true;
  bool _developerActionInProgress = false;
  bool _initializationComplete = false;
  Future<void> _pendingPreferenceWrites = Future.value();

  @override
  void updateProfile(ProfileViewModel newProfile) {
    super.updateProfile(newProfile);
    final reminder = newProfile.getHandler<AppSupportReminderProfileHandler>();
    if (_inited && !identical(_reminder, reminder)) skipReminderForSession();
    _reminder = reminder;
  }

  @override
  bool get mounted => _mounted;

  /// Whether initialization succeeded. Provider subscribers can now check UI safety.
  bool get inited => _inited;

  /// Includes failed initialization, so persistent content can still be shown.
  bool get initializationComplete => _initializationComplete;

  /// Permanent dismissal in the current profile, or false when it is absent.
  bool get reminderClosed => _reminder?.get()?.closed ?? false;

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
    final reminder = _reminder;
    final result = _pendingPreferenceWrites.then<bool>(
      (_) => !mounted || !identical(reminder, _reminder) ? false : action(),
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
  Future<bool> init() => _initFuture ??= _init();

  Future<bool> _init() async {
    if (!mounted) return false;
    try {
      if (!await profile.init() || !mounted) return false;
      _reminder = profile.getHandler<AppSupportReminderProfileHandler>();
      if (_reminder == null) return false;
      final history = _reminder!.get();
      final minimumDate = history?.minimumDate ?? _now().add(_reminderDelay);
      final launches = (history?.launches ?? 0) + 1;
      final closed = history?.closed ?? false;
      if (!await _saveReminderHistory(minimumDate, launches, closed)) {
        return false;
      }
      if (!mounted) return false;
      _inited = true;
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
    if (_reminderSkipped || !canShowDialog || !_inited) return false;
    final history = _reminder?.get();
    return history != null &&
        !history.closed &&
        history.launches >= _requiredLaunches &&
        _now().isAfter(history.minimumDate);
  }

  /// Saves the automatic reminder's result at most once per session.
  ///
  /// A failed save counts as the session's attempt and is not retried here.
  Future<bool> recordReminderResult(AppSupportResult result) async {
    if (!mounted || !_inited || _reminderSaveAttempted) return false;
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
    if (!mounted || !_inited) return false;
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
          final history = _reminder!.get();
          final restartCooldown =
              result == AppSupportResult.storeOpened ||
              result == AppSupportResult.remindLater;
          return await _saveReminderHistory(
            restartCooldown
                ? _now().add(_reminderDelay)
                : history?.minimumDate ?? _now().add(_reminderDelay),
            (history?.launches ?? 0) -
                (restartCooldown ? _requiredLaunches : 0),
            (history?.closed ?? false) ||
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

  /// Notifies listeners only after the complete reminder history has been saved.
  Future<bool> _saveReminderHistory(
    DateTime minimumDate,
    int launches,
    bool closed,
  ) async {
    final reminder = _reminder!;
    final saved = await reminder.set((
      minimumDate: minimumDate,
      launches: launches,
      closed: closed,
    ));
    if (!saved || !mounted || !identical(reminder, _reminder)) return false;
    if (_inited) notifyListeners();
    return true;
  }

  @override
  void dispose() {
    if (!mounted) return;
    _mounted = false;
    _reminder = null;
    skipReminderForSession();
    super.dispose();
  }
}
