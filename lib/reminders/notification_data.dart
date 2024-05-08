// Copyright 2023 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'notification_channel.dart';

part 'notification_data.g.dart';

@JsonEnum(valueField: "id")
enum NotificationDataType {
  debug(id: 1),
  habitReminder(id: 2),
  appReminder(id: 3),
  appDebugger(id: 4);

  final int id;

  const NotificationDataType({required this.id});
}

@JsonSerializable(genericArgumentFactories: true)
class NotificationData<T> {
  final int id;
  final NotificationDataType type;
  final String title;
  final String? body;
  final NotificationChannelId channelId;
  final DateTime? scheduledDate;
  final T? child;

  NotificationData({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.channelId,
    this.scheduledDate,
    this.child,
  });

  factory NotificationData.fromPayload(String json) {
    final j = jsonDecode(json);
    return _$NotificationDataFromJson(j, (_) => _decodeChildFromPayload(j));
  }

  static dynamic _decodeChildFromPayload(Map<String, Object?>? json) {}

  String toPayload() {
    return jsonEncode(_$NotificationDataToJson(this, _encodeChildFromPayload));
  }

  String? _encodeChildFromPayload(T value) => null;

  @override
  String toString() {
    return toPayload();
  }
}
