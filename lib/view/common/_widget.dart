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

export "./app_ui_layout_builder.dart";
export './appbar_combined_action.dart'
    show AppBarActions, AppbarActionItemConfig, AppbarActionShowStatus;
export './colorful_navibar.dart' show ColorfulNavibar;
export './contributor_tile.dart';
export './date_changer.dart';
export './donate_dialog.dart' show DonateDialogResult;
export './fixed_page_place_holder.dart';
export './habit_divider.dart';
export './habit_record_reason_modifier.dart' show HabitRecordReasonField;
export './habit_summary_list_tile.dart';
export './loglevel_changer_tile.dart';
export './not_found_image.dart';
export './page_loading_indicator.dart';
export './sync_loading_indicator.dart';
export './sync_now_tile.dart';

const kAppUndoDialogShowDuration = Duration(seconds: 4);
