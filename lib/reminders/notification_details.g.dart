// GENERATED CODE - DO NOT MODIFY BY HAND

// coverage: ignore-file
// ignore_for_file: type=lint


part of 'notification_details.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotificationDetailsCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// NotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationDetails call({
    AndroidNotificationDetails? android,
    DarwinNotificationDetails? iOS,
    DarwinNotificationDetails? macOS,
    LinuxNotificationDetails? linux,
    WindowsNotificationDetails? windows,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotificationDetails.copyWith(...)`.
class _$NotificationDetailsCWProxyImpl implements _$NotificationDetailsCWProxy {
  const _$NotificationDetailsCWProxyImpl(this._value);

  final NotificationDetails _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// NotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationDetails call({
    Object? android = const $CopyWithPlaceholder(),
    Object? iOS = const $CopyWithPlaceholder(),
    Object? macOS = const $CopyWithPlaceholder(),
    Object? linux = const $CopyWithPlaceholder(),
    Object? windows = const $CopyWithPlaceholder(),
  }) {
    return NotificationDetails(
      android: android == const $CopyWithPlaceholder()
          ? _value.android
          // ignore: cast_nullable_to_non_nullable
          : android as AndroidNotificationDetails?,
      iOS: iOS == const $CopyWithPlaceholder()
          ? _value.iOS
          // ignore: cast_nullable_to_non_nullable
          : iOS as DarwinNotificationDetails?,
      macOS: macOS == const $CopyWithPlaceholder()
          ? _value.macOS
          // ignore: cast_nullable_to_non_nullable
          : macOS as DarwinNotificationDetails?,
      linux: linux == const $CopyWithPlaceholder()
          ? _value.linux
          // ignore: cast_nullable_to_non_nullable
          : linux as LinuxNotificationDetails?,
      windows: windows == const $CopyWithPlaceholder()
          ? _value.windows
          // ignore: cast_nullable_to_non_nullable
          : windows as WindowsNotificationDetails?,
    );
  }
}

extension $NotificationDetailsCopyWith on NotificationDetails {
  /// Returns a callable class that can be used as follows: `instanceOfNotificationDetails.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationDetailsCWProxy get copyWith =>
      _$NotificationDetailsCWProxyImpl(this);
}

abstract class _$AndroidNotificationDetailsCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AndroidNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  AndroidNotificationDetails call({
    String channelId,
    String channelName,
    String? channelDescription,
    String? icon,
    Importance importance,
    bool channelBypassDnd,
    Priority priority,
    StyleInformation? styleInformation,
    bool playSound,
    AndroidNotificationSound? sound,
    bool enableVibration,
    Int64List? vibrationPattern,
    String? groupKey,
    bool setAsGroupSummary,
    GroupAlertBehavior groupAlertBehavior,
    bool autoCancel,
    bool ongoing,
    bool silent,
    Color? color,
    AndroidBitmap<Object>? largeIcon,
    bool onlyAlertOnce,
    bool showWhen,
    int? when,
    bool usesChronometer,
    bool chronometerCountDown,
    bool channelShowBadge,
    bool showProgress,
    int maxProgress,
    int progress,
    bool indeterminate,
    AndroidNotificationChannelAction channelAction,
    bool enableLights,
    Color? ledColor,
    int? ledOnMs,
    int? ledOffMs,
    String? ticker,
    NotificationVisibility? visibility,
    int? timeoutAfter,
    AndroidNotificationCategory? category,
    bool fullScreenIntent,
    String? shortcutId,
    Int32List? additionalFlags,
    String? subText,
    String? tag,
    List<AndroidNotificationAction>? actions,
    bool colorized,
    int? number,
    AudioAttributesUsage audioAttributesUsage,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAndroidNotificationDetails.copyWith(...)`.
class _$AndroidNotificationDetailsCWProxyImpl
    implements _$AndroidNotificationDetailsCWProxy {
  const _$AndroidNotificationDetailsCWProxyImpl(this._value);

  final AndroidNotificationDetails _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// AndroidNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  AndroidNotificationDetails call({
    Object? channelId = const $CopyWithPlaceholder(),
    Object? channelName = const $CopyWithPlaceholder(),
    Object? channelDescription = const $CopyWithPlaceholder(),
    Object? icon = const $CopyWithPlaceholder(),
    Object? importance = const $CopyWithPlaceholder(),
    Object? channelBypassDnd = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? styleInformation = const $CopyWithPlaceholder(),
    Object? playSound = const $CopyWithPlaceholder(),
    Object? sound = const $CopyWithPlaceholder(),
    Object? enableVibration = const $CopyWithPlaceholder(),
    Object? vibrationPattern = const $CopyWithPlaceholder(),
    Object? groupKey = const $CopyWithPlaceholder(),
    Object? setAsGroupSummary = const $CopyWithPlaceholder(),
    Object? groupAlertBehavior = const $CopyWithPlaceholder(),
    Object? autoCancel = const $CopyWithPlaceholder(),
    Object? ongoing = const $CopyWithPlaceholder(),
    Object? silent = const $CopyWithPlaceholder(),
    Object? color = const $CopyWithPlaceholder(),
    Object? largeIcon = const $CopyWithPlaceholder(),
    Object? onlyAlertOnce = const $CopyWithPlaceholder(),
    Object? showWhen = const $CopyWithPlaceholder(),
    Object? when = const $CopyWithPlaceholder(),
    Object? usesChronometer = const $CopyWithPlaceholder(),
    Object? chronometerCountDown = const $CopyWithPlaceholder(),
    Object? channelShowBadge = const $CopyWithPlaceholder(),
    Object? showProgress = const $CopyWithPlaceholder(),
    Object? maxProgress = const $CopyWithPlaceholder(),
    Object? progress = const $CopyWithPlaceholder(),
    Object? indeterminate = const $CopyWithPlaceholder(),
    Object? channelAction = const $CopyWithPlaceholder(),
    Object? enableLights = const $CopyWithPlaceholder(),
    Object? ledColor = const $CopyWithPlaceholder(),
    Object? ledOnMs = const $CopyWithPlaceholder(),
    Object? ledOffMs = const $CopyWithPlaceholder(),
    Object? ticker = const $CopyWithPlaceholder(),
    Object? visibility = const $CopyWithPlaceholder(),
    Object? timeoutAfter = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? fullScreenIntent = const $CopyWithPlaceholder(),
    Object? shortcutId = const $CopyWithPlaceholder(),
    Object? additionalFlags = const $CopyWithPlaceholder(),
    Object? subText = const $CopyWithPlaceholder(),
    Object? tag = const $CopyWithPlaceholder(),
    Object? actions = const $CopyWithPlaceholder(),
    Object? colorized = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? audioAttributesUsage = const $CopyWithPlaceholder(),
  }) {
    return AndroidNotificationDetails(
      channelId == const $CopyWithPlaceholder()
          ? _value.channelId
          // ignore: cast_nullable_to_non_nullable
          : channelId as String,
      channelName == const $CopyWithPlaceholder()
          ? _value.channelName
          // ignore: cast_nullable_to_non_nullable
          : channelName as String,
      channelDescription: channelDescription == const $CopyWithPlaceholder()
          ? _value.channelDescription
          // ignore: cast_nullable_to_non_nullable
          : channelDescription as String?,
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as String?,
      importance: importance == const $CopyWithPlaceholder()
          ? _value.importance
          // ignore: cast_nullable_to_non_nullable
          : importance as Importance,
      channelBypassDnd: channelBypassDnd == const $CopyWithPlaceholder()
          ? _value.channelBypassDnd
          // ignore: cast_nullable_to_non_nullable
          : channelBypassDnd as bool,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as Priority,
      styleInformation: styleInformation == const $CopyWithPlaceholder()
          ? _value.styleInformation
          // ignore: cast_nullable_to_non_nullable
          : styleInformation as StyleInformation?,
      playSound: playSound == const $CopyWithPlaceholder()
          ? _value.playSound
          // ignore: cast_nullable_to_non_nullable
          : playSound as bool,
      sound: sound == const $CopyWithPlaceholder()
          ? _value.sound
          // ignore: cast_nullable_to_non_nullable
          : sound as AndroidNotificationSound?,
      enableVibration: enableVibration == const $CopyWithPlaceholder()
          ? _value.enableVibration
          // ignore: cast_nullable_to_non_nullable
          : enableVibration as bool,
      vibrationPattern: vibrationPattern == const $CopyWithPlaceholder()
          ? _value.vibrationPattern
          // ignore: cast_nullable_to_non_nullable
          : vibrationPattern as Int64List?,
      groupKey: groupKey == const $CopyWithPlaceholder()
          ? _value.groupKey
          // ignore: cast_nullable_to_non_nullable
          : groupKey as String?,
      setAsGroupSummary: setAsGroupSummary == const $CopyWithPlaceholder()
          ? _value.setAsGroupSummary
          // ignore: cast_nullable_to_non_nullable
          : setAsGroupSummary as bool,
      groupAlertBehavior: groupAlertBehavior == const $CopyWithPlaceholder()
          ? _value.groupAlertBehavior
          // ignore: cast_nullable_to_non_nullable
          : groupAlertBehavior as GroupAlertBehavior,
      autoCancel: autoCancel == const $CopyWithPlaceholder()
          ? _value.autoCancel
          // ignore: cast_nullable_to_non_nullable
          : autoCancel as bool,
      ongoing: ongoing == const $CopyWithPlaceholder()
          ? _value.ongoing
          // ignore: cast_nullable_to_non_nullable
          : ongoing as bool,
      silent: silent == const $CopyWithPlaceholder()
          ? _value.silent
          // ignore: cast_nullable_to_non_nullable
          : silent as bool,
      color: color == const $CopyWithPlaceholder()
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color?,
      largeIcon: largeIcon == const $CopyWithPlaceholder()
          ? _value.largeIcon
          // ignore: cast_nullable_to_non_nullable
          : largeIcon as AndroidBitmap<Object>?,
      onlyAlertOnce: onlyAlertOnce == const $CopyWithPlaceholder()
          ? _value.onlyAlertOnce
          // ignore: cast_nullable_to_non_nullable
          : onlyAlertOnce as bool,
      showWhen: showWhen == const $CopyWithPlaceholder()
          ? _value.showWhen
          // ignore: cast_nullable_to_non_nullable
          : showWhen as bool,
      when: when == const $CopyWithPlaceholder()
          ? _value.when
          // ignore: cast_nullable_to_non_nullable
          : when as int?,
      usesChronometer: usesChronometer == const $CopyWithPlaceholder()
          ? _value.usesChronometer
          // ignore: cast_nullable_to_non_nullable
          : usesChronometer as bool,
      chronometerCountDown: chronometerCountDown == const $CopyWithPlaceholder()
          ? _value.chronometerCountDown
          // ignore: cast_nullable_to_non_nullable
          : chronometerCountDown as bool,
      channelShowBadge: channelShowBadge == const $CopyWithPlaceholder()
          ? _value.channelShowBadge
          // ignore: cast_nullable_to_non_nullable
          : channelShowBadge as bool,
      showProgress: showProgress == const $CopyWithPlaceholder()
          ? _value.showProgress
          // ignore: cast_nullable_to_non_nullable
          : showProgress as bool,
      maxProgress: maxProgress == const $CopyWithPlaceholder()
          ? _value.maxProgress
          // ignore: cast_nullable_to_non_nullable
          : maxProgress as int,
      progress: progress == const $CopyWithPlaceholder()
          ? _value.progress
          // ignore: cast_nullable_to_non_nullable
          : progress as int,
      indeterminate: indeterminate == const $CopyWithPlaceholder()
          ? _value.indeterminate
          // ignore: cast_nullable_to_non_nullable
          : indeterminate as bool,
      channelAction: channelAction == const $CopyWithPlaceholder()
          ? _value.channelAction
          // ignore: cast_nullable_to_non_nullable
          : channelAction as AndroidNotificationChannelAction,
      enableLights: enableLights == const $CopyWithPlaceholder()
          ? _value.enableLights
          // ignore: cast_nullable_to_non_nullable
          : enableLights as bool,
      ledColor: ledColor == const $CopyWithPlaceholder()
          ? _value.ledColor
          // ignore: cast_nullable_to_non_nullable
          : ledColor as Color?,
      ledOnMs: ledOnMs == const $CopyWithPlaceholder()
          ? _value.ledOnMs
          // ignore: cast_nullable_to_non_nullable
          : ledOnMs as int?,
      ledOffMs: ledOffMs == const $CopyWithPlaceholder()
          ? _value.ledOffMs
          // ignore: cast_nullable_to_non_nullable
          : ledOffMs as int?,
      ticker: ticker == const $CopyWithPlaceholder()
          ? _value.ticker
          // ignore: cast_nullable_to_non_nullable
          : ticker as String?,
      visibility: visibility == const $CopyWithPlaceholder()
          ? _value.visibility
          // ignore: cast_nullable_to_non_nullable
          : visibility as NotificationVisibility?,
      timeoutAfter: timeoutAfter == const $CopyWithPlaceholder()
          ? _value.timeoutAfter
          // ignore: cast_nullable_to_non_nullable
          : timeoutAfter as int?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as AndroidNotificationCategory?,
      fullScreenIntent: fullScreenIntent == const $CopyWithPlaceholder()
          ? _value.fullScreenIntent
          // ignore: cast_nullable_to_non_nullable
          : fullScreenIntent as bool,
      shortcutId: shortcutId == const $CopyWithPlaceholder()
          ? _value.shortcutId
          // ignore: cast_nullable_to_non_nullable
          : shortcutId as String?,
      additionalFlags: additionalFlags == const $CopyWithPlaceholder()
          ? _value.additionalFlags
          // ignore: cast_nullable_to_non_nullable
          : additionalFlags as Int32List?,
      subText: subText == const $CopyWithPlaceholder()
          ? _value.subText
          // ignore: cast_nullable_to_non_nullable
          : subText as String?,
      tag: tag == const $CopyWithPlaceholder()
          ? _value.tag
          // ignore: cast_nullable_to_non_nullable
          : tag as String?,
      actions: actions == const $CopyWithPlaceholder()
          ? _value.actions
          // ignore: cast_nullable_to_non_nullable
          : actions as List<AndroidNotificationAction>?,
      colorized: colorized == const $CopyWithPlaceholder()
          ? _value.colorized
          // ignore: cast_nullable_to_non_nullable
          : colorized as bool,
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as int?,
      audioAttributesUsage: audioAttributesUsage == const $CopyWithPlaceholder()
          ? _value.audioAttributesUsage
          // ignore: cast_nullable_to_non_nullable
          : audioAttributesUsage as AudioAttributesUsage,
    );
  }
}

extension $AndroidNotificationDetailsCopyWith on AndroidNotificationDetails {
  /// Returns a callable class that can be used as follows: `instanceOfAndroidNotificationDetails.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$AndroidNotificationDetailsCWProxy get copyWith =>
      _$AndroidNotificationDetailsCWProxyImpl(this);
}

abstract class _$DarwinNotificationDetailsCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// DarwinNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  DarwinNotificationDetails call({
    bool? presentAlert,
    bool? presentBadge,
    bool? presentSound,
    bool? presentBanner,
    bool? presentList,
    String? sound,
    int? badgeNumber,
    List<DarwinNotificationAttachment>? attachments,
    String? subtitle,
    String? threadIdentifier,
    String? categoryIdentifier,
    InterruptionLevel? interruptionLevel,
    double? criticalSoundVolume,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDarwinNotificationDetails.copyWith(...)`.
class _$DarwinNotificationDetailsCWProxyImpl
    implements _$DarwinNotificationDetailsCWProxy {
  const _$DarwinNotificationDetailsCWProxyImpl(this._value);

  final DarwinNotificationDetails _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// DarwinNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  DarwinNotificationDetails call({
    Object? presentAlert = const $CopyWithPlaceholder(),
    Object? presentBadge = const $CopyWithPlaceholder(),
    Object? presentSound = const $CopyWithPlaceholder(),
    Object? presentBanner = const $CopyWithPlaceholder(),
    Object? presentList = const $CopyWithPlaceholder(),
    Object? sound = const $CopyWithPlaceholder(),
    Object? badgeNumber = const $CopyWithPlaceholder(),
    Object? attachments = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
    Object? threadIdentifier = const $CopyWithPlaceholder(),
    Object? categoryIdentifier = const $CopyWithPlaceholder(),
    Object? interruptionLevel = const $CopyWithPlaceholder(),
    Object? criticalSoundVolume = const $CopyWithPlaceholder(),
  }) {
    return DarwinNotificationDetails(
      presentAlert: presentAlert == const $CopyWithPlaceholder()
          ? _value.presentAlert
          // ignore: cast_nullable_to_non_nullable
          : presentAlert as bool?,
      presentBadge: presentBadge == const $CopyWithPlaceholder()
          ? _value.presentBadge
          // ignore: cast_nullable_to_non_nullable
          : presentBadge as bool?,
      presentSound: presentSound == const $CopyWithPlaceholder()
          ? _value.presentSound
          // ignore: cast_nullable_to_non_nullable
          : presentSound as bool?,
      presentBanner: presentBanner == const $CopyWithPlaceholder()
          ? _value.presentBanner
          // ignore: cast_nullable_to_non_nullable
          : presentBanner as bool?,
      presentList: presentList == const $CopyWithPlaceholder()
          ? _value.presentList
          // ignore: cast_nullable_to_non_nullable
          : presentList as bool?,
      sound: sound == const $CopyWithPlaceholder()
          ? _value.sound
          // ignore: cast_nullable_to_non_nullable
          : sound as String?,
      badgeNumber: badgeNumber == const $CopyWithPlaceholder()
          ? _value.badgeNumber
          // ignore: cast_nullable_to_non_nullable
          : badgeNumber as int?,
      attachments: attachments == const $CopyWithPlaceholder()
          ? _value.attachments
          // ignore: cast_nullable_to_non_nullable
          : attachments as List<DarwinNotificationAttachment>?,
      subtitle: subtitle == const $CopyWithPlaceholder()
          ? _value.subtitle
          // ignore: cast_nullable_to_non_nullable
          : subtitle as String?,
      threadIdentifier: threadIdentifier == const $CopyWithPlaceholder()
          ? _value.threadIdentifier
          // ignore: cast_nullable_to_non_nullable
          : threadIdentifier as String?,
      categoryIdentifier: categoryIdentifier == const $CopyWithPlaceholder()
          ? _value.categoryIdentifier
          // ignore: cast_nullable_to_non_nullable
          : categoryIdentifier as String?,
      interruptionLevel: interruptionLevel == const $CopyWithPlaceholder()
          ? _value.interruptionLevel
          // ignore: cast_nullable_to_non_nullable
          : interruptionLevel as InterruptionLevel?,
      criticalSoundVolume: criticalSoundVolume == const $CopyWithPlaceholder()
          ? _value.criticalSoundVolume
          // ignore: cast_nullable_to_non_nullable
          : criticalSoundVolume as double?,
    );
  }
}

extension $DarwinNotificationDetailsCopyWith on DarwinNotificationDetails {
  /// Returns a callable class that can be used as follows: `instanceOfDarwinNotificationDetails.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$DarwinNotificationDetailsCWProxy get copyWith =>
      _$DarwinNotificationDetailsCWProxyImpl(this);
}

abstract class _$LinuxNotificationDetailsCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// LinuxNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  LinuxNotificationDetails call({
    LinuxNotificationIcon? icon,
    LinuxNotificationSound? sound,
    LinuxNotificationCategory? category,
    LinuxNotificationUrgency? urgency,
    LinuxNotificationTimeout timeout,
    bool resident,
    bool suppressSound,
    bool transient,
    LinuxNotificationLocation? location,
    String? defaultActionName,
    List<LinuxNotificationAction> actions,
    bool actionKeyAsIconName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLinuxNotificationDetails.copyWith(...)`.
class _$LinuxNotificationDetailsCWProxyImpl
    implements _$LinuxNotificationDetailsCWProxy {
  const _$LinuxNotificationDetailsCWProxyImpl(this._value);

  final LinuxNotificationDetails _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// LinuxNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  LinuxNotificationDetails call({
    Object? icon = const $CopyWithPlaceholder(),
    Object? sound = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? urgency = const $CopyWithPlaceholder(),
    Object? timeout = const $CopyWithPlaceholder(),
    Object? resident = const $CopyWithPlaceholder(),
    Object? suppressSound = const $CopyWithPlaceholder(),
    Object? transient = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? defaultActionName = const $CopyWithPlaceholder(),
    Object? actions = const $CopyWithPlaceholder(),
    Object? actionKeyAsIconName = const $CopyWithPlaceholder(),
  }) {
    return LinuxNotificationDetails(
      icon: icon == const $CopyWithPlaceholder()
          ? _value.icon
          // ignore: cast_nullable_to_non_nullable
          : icon as LinuxNotificationIcon?,
      sound: sound == const $CopyWithPlaceholder()
          ? _value.sound
          // ignore: cast_nullable_to_non_nullable
          : sound as LinuxNotificationSound?,
      category: category == const $CopyWithPlaceholder()
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as LinuxNotificationCategory?,
      urgency: urgency == const $CopyWithPlaceholder()
          ? _value.urgency
          // ignore: cast_nullable_to_non_nullable
          : urgency as LinuxNotificationUrgency?,
      timeout: timeout == const $CopyWithPlaceholder()
          ? _value.timeout
          // ignore: cast_nullable_to_non_nullable
          : timeout as LinuxNotificationTimeout,
      resident: resident == const $CopyWithPlaceholder()
          ? _value.resident
          // ignore: cast_nullable_to_non_nullable
          : resident as bool,
      suppressSound: suppressSound == const $CopyWithPlaceholder()
          ? _value.suppressSound
          // ignore: cast_nullable_to_non_nullable
          : suppressSound as bool,
      transient: transient == const $CopyWithPlaceholder()
          ? _value.transient
          // ignore: cast_nullable_to_non_nullable
          : transient as bool,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as LinuxNotificationLocation?,
      defaultActionName: defaultActionName == const $CopyWithPlaceholder()
          ? _value.defaultActionName
          // ignore: cast_nullable_to_non_nullable
          : defaultActionName as String?,
      actions: actions == const $CopyWithPlaceholder()
          ? _value.actions
          // ignore: cast_nullable_to_non_nullable
          : actions as List<LinuxNotificationAction>,
      actionKeyAsIconName: actionKeyAsIconName == const $CopyWithPlaceholder()
          ? _value.actionKeyAsIconName
          // ignore: cast_nullable_to_non_nullable
          : actionKeyAsIconName as bool,
    );
  }
}

extension $LinuxNotificationDetailsCopyWith on LinuxNotificationDetails {
  /// Returns a callable class that can be used as follows: `instanceOfLinuxNotificationDetails.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$LinuxNotificationDetailsCWProxy get copyWith =>
      _$LinuxNotificationDetailsCWProxyImpl(this);
}

abstract class _$WindowsNotificationDetailsCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WindowsNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  WindowsNotificationDetails call({
    List<WindowsAction> actions,
    List<WindowsInput> inputs,
    List<WindowsImage> images,
    List<WindowsRow> rows,
    List<WindowsProgressBar> progressBars,
    Map<String, String> bindings,
    WindowsHeader? header,
    WindowsNotificationAudio? audio,
    WindowsNotificationDuration? duration,
    WindowsNotificationScenario? scenario,
    DateTime? timestamp,
    String? subtitle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWindowsNotificationDetails.copyWith(...)`.
class _$WindowsNotificationDetailsCWProxyImpl
    implements _$WindowsNotificationDetailsCWProxy {
  const _$WindowsNotificationDetailsCWProxyImpl(this._value);

  final WindowsNotificationDetails _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// WindowsNotificationDetails(...).copyWith(id: 12, name: "My name")
  /// ````
  WindowsNotificationDetails call({
    Object? actions = const $CopyWithPlaceholder(),
    Object? inputs = const $CopyWithPlaceholder(),
    Object? images = const $CopyWithPlaceholder(),
    Object? rows = const $CopyWithPlaceholder(),
    Object? progressBars = const $CopyWithPlaceholder(),
    Object? bindings = const $CopyWithPlaceholder(),
    Object? header = const $CopyWithPlaceholder(),
    Object? audio = const $CopyWithPlaceholder(),
    Object? duration = const $CopyWithPlaceholder(),
    Object? scenario = const $CopyWithPlaceholder(),
    Object? timestamp = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
  }) {
    return WindowsNotificationDetails(
      actions: actions == const $CopyWithPlaceholder()
          ? _value.actions
          // ignore: cast_nullable_to_non_nullable
          : actions as List<WindowsAction>,
      inputs: inputs == const $CopyWithPlaceholder()
          ? _value.inputs
          // ignore: cast_nullable_to_non_nullable
          : inputs as List<WindowsInput>,
      images: images == const $CopyWithPlaceholder()
          ? _value.images
          // ignore: cast_nullable_to_non_nullable
          : images as List<WindowsImage>,
      rows: rows == const $CopyWithPlaceholder()
          ? _value.rows
          // ignore: cast_nullable_to_non_nullable
          : rows as List<WindowsRow>,
      progressBars: progressBars == const $CopyWithPlaceholder()
          ? _value.progressBars
          // ignore: cast_nullable_to_non_nullable
          : progressBars as List<WindowsProgressBar>,
      bindings: bindings == const $CopyWithPlaceholder()
          ? _value.bindings
          // ignore: cast_nullable_to_non_nullable
          : bindings as Map<String, String>,
      header: header == const $CopyWithPlaceholder()
          ? _value.header
          // ignore: cast_nullable_to_non_nullable
          : header as WindowsHeader?,
      audio: audio == const $CopyWithPlaceholder()
          ? _value.audio
          // ignore: cast_nullable_to_non_nullable
          : audio as WindowsNotificationAudio?,
      duration: duration == const $CopyWithPlaceholder()
          ? _value.duration
          // ignore: cast_nullable_to_non_nullable
          : duration as WindowsNotificationDuration?,
      scenario: scenario == const $CopyWithPlaceholder()
          ? _value.scenario
          // ignore: cast_nullable_to_non_nullable
          : scenario as WindowsNotificationScenario?,
      timestamp: timestamp == const $CopyWithPlaceholder()
          ? _value.timestamp
          // ignore: cast_nullable_to_non_nullable
          : timestamp as DateTime?,
      subtitle: subtitle == const $CopyWithPlaceholder()
          ? _value.subtitle
          // ignore: cast_nullable_to_non_nullable
          : subtitle as String?,
    );
  }
}

extension $WindowsNotificationDetailsCopyWith on WindowsNotificationDetails {
  /// Returns a callable class that can be used as follows: `instanceOfWindowsNotificationDetails.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$WindowsNotificationDetailsCWProxy get copyWith =>
      _$WindowsNotificationDetailsCWProxyImpl(this);
}
