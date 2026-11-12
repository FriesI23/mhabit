// Copyright 2026 Fries_I23
// Licensed under the Apache License, Version 2.0.

import 'dart:convert';

import '../../../common/types.dart';
import '../../../models/app_support.dart';
import '../profile_helper.dart';

final class AppSupportReminderProfileHandler
    extends ProfileHelperCovertToJsonHandler<AppSupportReminderHistory> {
  const AppSupportReminderProfileHandler(super.pref)
    : super(codec: const AppSupportReminderProfileCodec());

  @override
  String get key => 'appSupportReminder';
}

final class AppSupportReminderProfileCodec
    extends Codec<AppSupportReminderHistory, JsonMap> {
  const AppSupportReminderProfileCodec();

  @override
  Converter<JsonMap, AppSupportReminderHistory> get decoder => const _Decoder();

  @override
  Converter<AppSupportReminderHistory, JsonMap> get encoder => const _Encoder();
}

final class _Decoder extends Converter<JsonMap, AppSupportReminderHistory> {
  const _Decoder();

  @override
  AppSupportReminderHistory convert(JsonMap input) => (
    minimumDate: DateTime.fromMillisecondsSinceEpoch(
      input['minimumDate'] as int,
      isUtc: true,
    ),
    launches: input['launches'] as int,
    closed: input['closed'] as bool,
  );
}

final class _Encoder extends Converter<AppSupportReminderHistory, JsonMap> {
  const _Encoder();

  @override
  JsonMap convert(AppSupportReminderHistory input) => {
    'minimumDate': input.minimumDate.millisecondsSinceEpoch,
    'launches': input.launches,
    'closed': input.closed,
  };
}
