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

import '../../model/habit_form.dart';
import '../../widgets/widget.dart';

class HabitEditColorTile extends StatelessWidget {
  final HabitColorType colorType;
  final void Function(BuildContext context, HabitColorType colorType)?
      onPressed;

  const HabitEditColorTile({
    super.key,
    required this.colorType,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color: Theme.of(context).colorScheme.outline,
      ),
      title: ColorDisplayChip(colorType),
      onTap: () => onPressed?.call(context, colorType),
    );
  }
}
