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

class GroupTitleListTile extends StatelessWidget {
  final Widget? title;
  final Color? textColor;
  final EdgeInsetsGeometry? contentPadding;

  const GroupTitleListTile({
    super.key,
    this.title,
    this.textColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: title,
      textColor: textColor ?? Theme.of(context).colorScheme.primary,
      contentPadding: contentPadding,
    );
  }
}
