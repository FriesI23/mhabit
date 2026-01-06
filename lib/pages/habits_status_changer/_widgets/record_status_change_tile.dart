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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../common/consts.dart';
import '../../../l10n/localizations.dart';
import '../../../logging/helper.dart';
import '../../../providers/habit_status_changer.dart';

class RecordStatusChangeTile extends StatefulWidget {
  final RecordStatusChangerStatus? initStatus;
  final Set<RecordStatusChangerStatus> allowedStatus;
  final void Function(
    RecordStatusChangerStatus? os,
    RecordStatusChangerStatus? ns,
  )?
  onSelectedNewStatus;

  const RecordStatusChangeTile({
    super.key,
    this.initStatus,
    required this.allowedStatus,
    this.onSelectedNewStatus,
  });

  @override
  State<StatefulWidget> createState() => _RecordStatusChangeTile();
}

class _RecordStatusChangeTile extends State<RecordStatusChangeTile> {
  RecordStatusChangerStatus? selectStatus;

  @override
  void initState() {
    selectStatus = widget.initStatus;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RecordStatusChangeTile oldWdiget) {
    selectStatus = widget.initStatus;
    super.didUpdateWidget(oldWdiget);
  }

  Set<RecordStatusChangerStatus> get currentSelection => {
    if (selectStatus != null) selectStatus!,
  };

  void _onSelectionChanged(Set<RecordStatusChangerStatus> newSelection) {
    if (currentSelection == newSelection) return;
    setState(() {
      final oldStatus = selectStatus;
      selectStatus = newSelection.firstOrNull;
      widget.onSelectedNewStatus?.call(oldStatus, selectStatus);
    });
  }

  String? _getTooltipByStatus(RecordStatusChangerStatus status, [L10n? l10n]) {
    switch (status) {
      case RecordStatusChangerStatus.skip:
        return l10n?.batchCheckin_status_skip_text;
      case RecordStatusChangerStatus.ok:
        return l10n?.batchCheckin_status_ok_text;
      case RecordStatusChangerStatus.dual:
        return l10n?.batchCheckin_status_double_text;
      case RecordStatusChangerStatus.zero:
        return l10n?.batchCheckin_status_zero_text;
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonSegment<RecordStatusChangerStatus> buildButtonSegment(
      BuildContext context, {
      required RecordStatusChangerStatus status,
      Widget? label,
      Widget? icon,
    }) => ButtonSegment(
      value: status,
      label: label,
      icon: icon,
      tooltip: _getTooltipByStatus(status, L10n.of(context)),
      enabled: widget.allowedStatus.contains(status),
    );

    appLog.build.debug(context);
    return ListTile(
      title: SegmentedButton<RecordStatusChangerStatus>(
        segments: [
          buildButtonSegment(
            context,
            status: RecordStatusChangerStatus.skip,
            icon: const Icon(kRecordSkipStatusIcon),
          ),
          buildButtonSegment(
            context,
            status: RecordStatusChangerStatus.ok,
            icon: const Icon(kRecordDoneStatusIcon),
          ),
          buildButtonSegment(
            context,
            status: RecordStatusChangerStatus.dual,
            icon: const Icon(MdiIcons.checkAll),
          ),
          buildButtonSegment(
            context,
            status: RecordStatusChangerStatus.zero,
            icon: const Icon(kRecordZeroStatusIcon),
          ),
        ],
        selected: currentSelection,
        onSelectionChanged: _onSelectionChanged,
        emptySelectionAllowed: true,
        showSelectedIcon: false,
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
    );
  }
}
