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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

import '../../../common/enums.dart';
import '../../../l10n/localizations.dart';
import '../../../widgets/widgets.dart';

class AppSettingDisplayRecordOperationTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final UserAction inputAction;
  final bool useSideBySideLayout;
  final void Function(UserAction selectedAction)? onSelected;

  const AppSettingDisplayRecordOperationTile({
    super.key,
    this.title,
    this.subtitle,
    required this.inputAction,
    this.useSideBySideLayout = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) => switch (AdaptiveStyle.of(context)) {
    AdaptiveStyle.material => _MaterialAppSettingDisplayRecordOperationTile(
      title: title,
      subtitle: subtitle,
      inputAction: inputAction,
      useSideBySideLayout: useSideBySideLayout,
      onSelected: onSelected,
    ),
    AdaptiveStyle.apple => _AppleAppSettingDisplayRecordOperationTile(
      title: title,
      subtitle: subtitle,
      inputAction: inputAction,
      onSelected: onSelected,
      useSideBySideLayout: useSideBySideLayout,
    ),
  };
}

class _MaterialAppSettingDisplayRecordOperationTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final UserAction inputAction;
  final bool useSideBySideLayout;
  final void Function(UserAction selectedAction)? onSelected;

  const _MaterialAppSettingDisplayRecordOperationTile({
    this.title,
    this.subtitle,
    required this.inputAction,
    this.useSideBySideLayout = false,
    this.onSelected,
  });

  Icon? _getActionIcon(UserAction action) {
    switch (action) {
      case UserAction.nothing:
        return null;
      case UserAction.tap:
        return const Icon(MdiIcons.gestureTap);
      case UserAction.longTap:
        return const Icon(MdiIcons.gestureTapHold);
      case UserAction.doubleTap:
        return const Icon(MdiIcons.gestureDoubleTap);
    }
  }

  String? _getActionText(UserAction action, [L10n? l10n]) {
    switch (action) {
      case UserAction.nothing:
        return null;
      case UserAction.tap:
        return l10n?.userAction_tap;
      case UserAction.doubleTap:
        return l10n?.userAction_doubleTap;
      case UserAction.longTap:
        return l10n?.userAction_longTap;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildSegmentedTile(BuildContext context, [L10n? l10n]) {
      final selected = <UserAction>{inputAction};

      ButtonSegment<UserAction> getButtonSegment(UserAction action) =>
          ButtonSegment<UserAction>(
            value: action,
            icon: _getActionIcon(action),
            label: l10n != null
                ? Text(
                    _getActionText(action, l10n) ?? '',
                    overflow: selected.contains(action)
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    maxLines: selected.contains(action) ? null : 1,
                  )
                : null,
          );

      return SegmentedButton<UserAction>(
        segments: <ButtonSegment<UserAction>>[
          getButtonSegment(UserAction.tap),
          getButtonSegment(UserAction.doubleTap),
          getButtonSegment(UserAction.longTap),
        ],
        selected: selected,
        onSelectionChanged: onSelected != null
            ? (selectedSet) => onSelected!(
                selectedSet.isNotEmpty ? selectedSet.first : UserAction.nothing,
              )
            : null,
        style: const ButtonStyle(visualDensity: VisualDensity(vertical: -2)),
      );
    }

    Widget buildNormalSubtitle(BuildContext context, [L10n? l10n]) => Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (subtitle != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: double.infinity),
            child: subtitle,
          ),
          const SizedBox(height: 8.0),
        ],
        buildSegmentedTile(context, l10n),
      ],
    );

    Widget buildBigViewSubtitle(BuildContext context, [L10n? l10n]) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (subtitle != null) ...[
          Flexible(flex: 5, child: subtitle!),
          const Spacer(flex: 1),
        ],
        buildSegmentedTile(context, l10n),
      ],
    );

    return L10nBuilder(
      builder: (context, l10n) => AdaptiveListTile.material(
        title: title ?? const SizedBox.shrink(),
        subtitle: useSideBySideLayout
            ? buildBigViewSubtitle(context, l10n)
            : buildNormalSubtitle(context, l10n),
      ),
    );
  }
}

class _AppleAppSettingDisplayRecordOperationTile extends StatelessWidget {
  final bool useSideBySideLayout;
  final Widget? title;
  final Widget? subtitle;
  final UserAction inputAction;
  final void Function(UserAction selectedAction)? onSelected;

  const _AppleAppSettingDisplayRecordOperationTile({
    required this.useSideBySideLayout,
    this.title,
    this.subtitle,
    required this.inputAction,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AdaptiveChoiceListTile<UserAction>.apple(
      title: title ?? const SizedBox.shrink(),
      subtitle: subtitle,
      config: AdaptiveChoiceListTileConfig(
        segmented: useSideBySideLayout
            ? AdaptiveChoiceLayout.responsive
            : AdaptiveChoiceLayout.stacked,
      ),
      value: inputAction == UserAction.nothing ? null : inputAction,
      onChanged: onSelected,
      labels: {
        for (final option in [
          UserAction.tap,
          UserAction.doubleTap,
          UserAction.longTap,
        ])
          option: switch (option) {
            UserAction.tap => l10n?.userAction_tap ?? 'Tap',
            UserAction.doubleTap => l10n?.userAction_doubleTap ?? 'Double tap',
            UserAction.longTap => l10n?.userAction_longTap ?? 'Long press',
            UserAction.nothing => '',
          },
      },
    );
  }
}
