// Copyright 2025 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/types.dart';
import '../reminders/notification_channel.dart';
import 'common.dart';

part 'app_notify_config.g.dart';

JsonMap channelsToJson(Map<NotificationChannelId, bool> channels) =>
    Map.fromEntries(
        channels.entries.map((e) => MapEntry(e.key.id.toString(), e.value)));

Map<NotificationChannelId, bool> channelsFromJson(JsonMap input) {
  final result = <NotificationChannelId, bool>{};
  for (final MapEntry(key: key, value: value as bool) in input.entries) {
    final channelId = NotificationChannelId.values
        .firstWhereOrNull((id) => id.id == int.tryParse(key));
    if (channelId == null) continue;
    result[channelId] = value;
  }
  return result;
}

@JsonSerializable(constructor: "_")
class AppNotifyConfig implements JsonAdaptor {
  final Map<NotificationChannelId, bool> _channels;

  const AppNotifyConfig({Map<NotificationChannelId, bool>? channels})
      : _channels = channels ?? const {};

  AppNotifyConfig._({required Map<NotificationChannelId, bool> channels})
      : _channels = channels;

  factory AppNotifyConfig.fromJson(JsonMap json) =>
      _$AppNotifyConfigFromJson(json);

  @JsonKey(
      name: "channels",
      includeFromJson: true,
      includeToJson: true,
      toJson: channelsToJson,
      fromJson: channelsFromJson)
  @visibleForTesting
  Map<NotificationChannelId, bool> get channels => _channels;

  bool isChannelEnabled(NotificationChannelId id) => _channels[id] != false;

  @override
  JsonMap toJson() => _$AppNotifyConfigToJson(this);

  AppNotifyConfig copyWith(Map<NotificationChannelId, bool?> channels) {
    final newChannels = {..._channels};
    for (final MapEntry(key: key, value: value) in channels.entries) {
      value != null ? newChannels[key] = value : newChannels.remove(key);
    }
    return AppNotifyConfig(channels: newChannels);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppNotifyConfig &&
        const MapEquality().equals(toJson(), other.toJson());
  }

  @override
  int get hashCode => const MapEquality().hash(_channels);
}
