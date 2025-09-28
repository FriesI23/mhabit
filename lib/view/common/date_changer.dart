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
import 'package:provider/provider.dart';

import '../../widgets/provider.dart';
import '../../widgets/widget.dart';

class DateChanger extends StatelessWidget {
  final Duration interval;
  final WidgetBuilder builder;

  const DateChanger({
    super.key,
    this.interval = const Duration(seconds: 1),
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DateChangeNotifier(),
      child: DateChangeBuilder(
        interval: interval,
        builder: builder,
      ),
    );
  }
}
