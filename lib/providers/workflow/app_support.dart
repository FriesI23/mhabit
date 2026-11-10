// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'package:flutter/foundation.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../logging/helper.dart';
import '../../models/app_sync_server.dart';
import '../support/about_info.dart';

/// A completed interaction, distinct from a route being removed or destroyed.
enum AppSupportPromptResult { githubOpened, later, never, aborted }

/// Owns the reminder for one foreground app lifetime, independently of routes.
///
/// Only the package owns dates, launch counts and persisted dismissal state.
class AppSupportOwner extends ChangeNotifier {
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
  bool _disposed = false;
  bool _developerActionInProgress = false;

  /// Whether initialization succeeded. Provider subscribers can now check UI safety.
  bool get initialized => _initialized;

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
      !_disposed &&
      !_blocked &&
      !processing &&
      !(enabled && server is AppWebDavSyncServer && !server.configed);

  Future<Uri?> _loadTarget() async {
    final info = await _loadInfo();
    final target = Uri.tryParse(info.sourceCodeUrl);
    if (target == null ||
        (target.scheme != 'https' && target.scheme != 'http') ||
        target.host.isEmpty ||
        target.userInfo.isNotEmpty) {
      appLog.load.info('AppSupportOwner.invalidTarget');
      return null;
    }
    return target;
  }

  /// Arms package-owned eligibility for the next full launch, without prompting now.
  ///
  /// Developer tooling only: unlike RateMyApp.reset, this also bypasses the
  /// initial day/launch thresholds. Normal startup safety checks still apply.
  Future<bool> resetForNextLaunch() async {
    if (_disposed || _developerActionInProgress) return false;
    _developerActionInProgress = true;
    notifyListeners();
    skipPrompt();
    try {
      if (!await initialize() || _disposed) return false;
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
      return true;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.resetForNextLaunch',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _developerActionInProgress = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Previews the production dialog without claiming eligibility or saving an event.
  Future<bool> previewPrompt({
    required bool Function() canPresent,
    required Future<AppSupportPromptResult> Function(Uri target) showPrompt,
  }) async {
    if (_disposed || _developerActionInProgress) return false;
    _developerActionInProgress = true;
    notifyListeners();
    skipPrompt();
    try {
      final target = await _loadTarget();
      if (_disposed || target == null || !canPresent()) return false;
      return await showPrompt(target) != AppSupportPromptResult.aborted;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.previewPrompt',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      _developerActionInProgress = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Shares success or failure; a failed initialization is not retried.
  Future<bool> initialize() => _initialization ??= _initialize();

  Future<bool> _initialize() async {
    try {
      await _reminder.init();
      if (_disposed) return false;
      _initialized = true;
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.initialize',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
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
    required Future<AppSupportPromptResult> Function(Uri target) showPrompt,
  }) => _promptCheck ??= _checkPrompt(canPresent, showPrompt);

  Future<void> _checkPrompt(
    bool Function() canPresent,
    Future<AppSupportPromptResult> Function(Uri target) showPrompt,
  ) async {
    try {
      if (!await initialize()) return;
      if (!claimPrompt(canPresent: canPresent())) return;
      final target = await _loadTarget();
      if (target == null) return;
      if (_blocked || !canPresent()) return;
      await consume(await showPrompt(target));
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
    if (_disposed ||
        !_initialized ||
        _consumed ||
        result == AppSupportPromptResult.aborted) {
      return false;
    }
    _consumed = true;
    final event = switch (result) {
      AppSupportPromptResult.githubOpened =>
        RateMyAppEventType.rateButtonPressed,
      AppSupportPromptResult.later => RateMyAppEventType.laterButtonPressed,
      AppSupportPromptResult.never => RateMyAppEventType.noButtonPressed,
      AppSupportPromptResult.aborted => throw StateError('No user action'),
    };
    try {
      await _reminder.callEvent(event);
      return true;
    } catch (error, stackTrace) {
      appLog.load.warn(
        'AppSupportOwner.consume',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    skipPrompt();
    super.dispose();
  }
}
