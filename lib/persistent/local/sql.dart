// Copyright 2024 Fries_I23
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

import 'table.dart';

class CustomSql {
  static const String autoUpdateRecordsModifyTimeTrigger = """
CREATE TRIGGER auto_update_mh_records_modify_t
AFTER UPDATE ON ${TableName.records}
BEGIN
  UPDATE ${TableName.records}
  SET modify_t = (cast(strftime('%s','now') as int))
  WHERE uuid = NEW.uuid;
END""";

  static const String autoUpdateHabitssModifyTimeTrigger = """
CREATE TRIGGER auto_update_mh_habits_modify_t
AFTER UPDATE ON ${TableName.habits}
BEGIN
  UPDATE ${TableName.habits}
  SET modify_t = (cast(strftime('%s','now') as int))
  WHERE uuid = NEW.uuid;
END
""";

  static const String autoAddSortPostionWhenAddNewHabit = """
CREATE TRIGGER auto_insert_mh_habits_sort_position
AFTER INSERT ON ${TableName.habits}
BEGIN
  UPDATE ${TableName.habits}
  SET sort_position = NEW.id_
  WHERE uuid = NEW.uuid;
END
""";
}
