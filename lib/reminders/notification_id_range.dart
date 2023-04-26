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

import 'dart:math';

import '../common/exceptions.dart';
import '../common/logging.dart';
import 'notification_data.dart';

/// ID range
/// ` -0x80000000 -> -0x40000000` : habitReminder id (reserved)
/// ` -0x00000101`                : app remind id
/// ` -0x00000100 -> -0x00000001` : debug id
/// `  0x00000000 ->  0x7FFFFFFE` : habitReminder id

const minHabitReminderNotifyId = 0;
const maxHabitReminderNotifyId = 0x7FFFFFFE;
const minDebugReverseNotifyId = -0x00000100;
const maxDebugReverseNotifyId = -0x00000001;
const minHabitReminderReserveNotifyId = -0x80000000;
const maxHabitReminderReserveNotifyId = -0x40000000;
const appReminderNotifyId = -0x00000101;

bool isValidHabitReminderId(int id) =>
    (id >= minHabitReminderNotifyId && id <= maxHabitReminderNotifyId) ||
    (id >= minHabitReminderReserveNotifyId &&
        id <= maxHabitReminderReserveNotifyId);

bool isValidDebugId(int id) =>
    (id >= minDebugReverseNotifyId && id <= maxDebugReverseNotifyId);

int getHabitReminderId(int id, {bool fallback = true}) {
  if (isValidHabitReminderId(id)) {
    return id;
  } else {
    if (!fallback) {
      throw NotificationIdOutOfDefinedRange(id,
          type: NotificationDataType.habitReminder);
    }
    const reserveRange =
        maxHabitReminderReserveNotifyId - minHabitReminderReserveNotifyId + 1;
    final reserverId = (id % reserveRange) + minHabitReminderReserveNotifyId;
    WarnLog.notify("getHabitReminderId fallback, id=$id, rid=$reserverId");
    return reserverId;
  }
}

int getHabitDebugId(int id) {
  if (!isValidHabitReminderId(id)) {
    throw NotificationIdOutOfDefinedRange(id, type: NotificationDataType.debug);
  }
  return id;
}

int getRandomDebugId() {
  return minDebugReverseNotifyId +
      Random().nextInt(maxDebugReverseNotifyId - minDebugReverseNotifyId + 1);
}
