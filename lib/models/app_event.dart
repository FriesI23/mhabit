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

import '../common/types.dart';
import 'habit_form.dart';

abstract interface class AppEvent {}

final class ReloadDataEvent implements AppEvent {
  final String? msg;
  final bool exiEditMode;
  final bool clearSnackBar;

  const ReloadDataEvent({
    this.msg,
    this.exiEditMode = false,
    this.clearSnackBar = false,
  });

  @override
  String toString() {
    final bf = StringBuffer("ReloadDataEvent(");
    final data = <String>[
      if (msg != null) "msg=$msg",
      "exiEditMode=$exiEditMode",
      "clearSnackBar=$clearSnackBar"
    ];
    bf.writeAll(data, ",");
    bf.write(")");
    return bf.toString();
  }
}

final class HabitStatusChangedEvent implements AppEvent {
  final String? msg;
  final List<HabitUUID> uuidList;
  final HabitStatus status;

  const HabitStatusChangedEvent({
    this.msg,
    required this.uuidList,
    required this.status,
  });

  @override
  String toString() {
    final bf = StringBuffer("HabitStatusChangedEvent(");
    final data = <String>[
      if (msg != null) "msg=$msg",
      "uuidList=$uuidList",
      "status=$status"
    ];
    bf.writeAll(data, ",");
    bf.write(")");
    return bf.toString();
  }
}
