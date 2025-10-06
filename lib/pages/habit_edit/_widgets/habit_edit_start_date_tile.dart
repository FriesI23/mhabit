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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/habit_date.dart';

class HabitEditStartDateTile extends StatelessWidget {
  static const fullDateFormat = "E, MMM d, y";

  final HabitDate startDate;
  final void Function(BuildContext context, HabitDate date)? onPressed;

  const HabitEditStartDateTile({
    super.key,
    required this.startDate,
    this.onPressed,
  });

  DateFormat _getDateFormat(BuildContext context) => DateFormat(
      fullDateFormat, Localizations.localeOf(context).toLanguageTag());

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.schedule_outlined,
        color: Theme.of(context).colorScheme.outline,
      ),
      title: Text(_getDateFormat(context).format(startDate)),
      onTap: () => onPressed?.call(context, startDate),
    );
  }
}
