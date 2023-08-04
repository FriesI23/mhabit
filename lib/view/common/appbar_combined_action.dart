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

enum AppbarActionShowStatus {
  button,
  popupitem,
}

abstract class AppbarActionItemConfig<T> {
  final T type;
  final AppbarActionShowStatus status;
  final bool visible;
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback? callback;

  const AppbarActionItemConfig({
    required this.type,
    required this.status,
    required this.visible,
    required this.icon,
    required this.text,
    this.color,
    this.callback,
  });

  const AppbarActionItemConfig.button({
    required this.type,
    required this.visible,
    required this.icon,
    required this.text,
    this.color,
    this.callback,
  }) : status = AppbarActionShowStatus.button;

  const AppbarActionItemConfig.popupitem({
    required this.type,
    required this.visible,
    required this.icon,
    required this.text,
    this.color,
    this.callback,
  }) : status = AppbarActionShowStatus.popupitem;

  bool shouldShow(AppbarActionShowStatus s);
}

class AppBarActions<C extends AppbarActionItemConfig, I>
    extends StatelessWidget {
  final Duration buttonSwitchAnimateDuration;
  final Widget? popupMenuButtonIcon;
  final List<C> actionConfigs;

  const AppBarActions({
    super.key,
    this.buttonSwitchAnimateDuration = Duration.zero,
    this.popupMenuButtonIcon,
    this.actionConfigs = const [],
  });

  List<PopupMenuItem<I>> _getPopupItemList(BuildContext context) {
    PopupMenuItem<I> getPopupItem(BuildContext context, C config) {
      return PopupMenuItem<I>(
        value: config.type,
        child: ListTile(
          title: Text(config.text),
          leading: Icon(config.icon, color: config.color),
        ),
      );
    }

    List<PopupMenuItem<I>> children = [];
    for (var config in actionConfigs) {
      if (config.shouldShow(AppbarActionShowStatus.popupitem)) {
        children.add(getPopupItem(context, config));
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    Widget buildActionButton(BuildContext context, C config) {
      return AnimatedSwitcher(
        duration: buttonSwitchAnimateDuration,
        switchInCurve: Curves.easeInQuart,
        child: config.visible
            ? _ActionItemButton<C>(config: config)
            : const SizedBox(),
      );
    }

    List<Widget> children = [];
    for (var config in actionConfigs) {
      if (config.shouldShow(AppbarActionShowStatus.button)) {
        children.add(buildActionButton(context, config));
      }
    }

    return Row(
      children: [
        ...children,
        PopupMenuButton<I>(
          padding: EdgeInsets.zero,
          icon: popupMenuButtonIcon,
          onSelected: (value) {
            for (var config in actionConfigs) {
              if (config.type == value) {
                config.callback?.call();
                break;
              }
            }
          },
          itemBuilder: (context) => _getPopupItemList(context),
        ),
      ],
    );
  }
}

class _ActionItemButton<C extends AppbarActionItemConfig>
    extends StatelessWidget {
  final C config;

  const _ActionItemButton({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: config.callback,
      icon: Icon(config.icon, color: config.color),
      tooltip: config.text,
    );
  }
}
