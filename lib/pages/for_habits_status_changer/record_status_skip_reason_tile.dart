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

import 'package:flutter/material.dart';

import '../../common/consts.dart';
import '../common/_widget.dart';

class RecordStatusSkipReasonTile extends StatelessWidget {
  final TextEditingController inputController;

  const RecordStatusSkipReasonTile({super.key, required this.inputController});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: HabitRecordReasonField(
        chipTextList: skipReasonChipTextList,
        inputController: inputController,
      ),
    );
  }
}
