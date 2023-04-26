@rem Copyright 2023 Fries_I23
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem     http://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.

(
flutter pub run icon_font_generator ^
--from=assets/icons/sort_icons ^
--class-name=HabitSortIcons ^
--out-font=assets/fonts/sort_icons.ttf ^
--out-flutter=lib/theme/_icons/sort_icons.g.dart
) & (
flutter pub run icon_font_generator ^
--from=assets/icons/calendar_icons ^
--class-name=HabitCalIcons ^
--out-font=assets/fonts/cal_icons.ttf ^
--out-flutter=lib/theme/_icons/cal_icons.g.dart
) & (
flutter pub run icon_font_generator ^
--from=assets/icons/progress_icons ^
--class-name=HabitProgressIcons ^
--out-font=assets/fonts/progress_icons.ttf ^
--out-flutter=lib/theme/_icons/progress_icons.g.dart
) & (
flutter pub run icon_font_generator ^
--from=assets/icons/common_icons ^
--class-name=CommonIcons ^
--out-font=assets/fonts/common_icons.ttf ^
--out-flutter=lib/theme/_icons/common_icons.g.dart
)