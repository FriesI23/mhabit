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
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../common/utils.dart';
import '../../extensions/context_extensions.dart';
import '../../extensions/navigator_extensions.dart';
import '../../models/app_entry.dart';
import '../../storage/profile/handlers/app_launch_entry.dart';
import '../../storage/profile_provider.dart';
import '../../widgets/widgets.dart';
import 'page_habits.dart';
import 'page_today.dart';
import 'providers.dart';

enum _PageTabs { display, today }

/// Depend Providers
/// - Required for builder:
///   - [AppThemeViewModel]
///   - [AppCompactUISwitcherViewModel]
class HabitsDisplayPage extends StatelessWidget {
  const HabitsDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageProviders(child: _Page());
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<StatefulWidget> createState() => _PageState();
}

class _PageState extends State<_Page> {
  static const Duration _bottomNavAnimationDuration = Duration(
    milliseconds: 250,
  );

  int _currentTabIndex = 0;
  bool _isBottomNavVisible = true;
  bool _fabRebuildPending = false;

  final GlobalKey<HabitsTabPageState> _habitsTabKey = GlobalKey();
  final GlobalKey<TodayTabPageState> _todayTabKey = GlobalKey();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final entryPoint = context
        .maybeRead<ProfileViewModel>()
        ?.getHandler<AppLaunchEntryProfileHandler>()
        ?.get();
    _currentTabIndex = switch (entryPoint) {
      AppEntrys.habitToday => _PageTabs.today.index,
      _ => 0,
    };
    _pageController = PageController(initialPage: _currentTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleBottomNavVisibilityChanged(bool visible) {
    if (_isBottomNavVisible == visible) return;
    setState(() => _isBottomNavVisible = visible);
  }

  Widget? _buildFloatingActionButton(double bottomNavHeight) {
    if (_currentTabIndex != _PageTabs.display.index) return null;
    final state = _habitsTabKey.currentState;
    if (state == null) {
      if (!_fabRebuildPending) {
        _fabRebuildPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _fabRebuildPending = false;
          setState(() {});
        });
      }
      return null;
    }
    return state.buildFloatingActionButton(
      bottomNavVisible: _isBottomNavVisible,
      bottomNavHeight: bottomNavHeight,
    );
  }

  Future<bool> _handleWillPop() async {
    if (_currentTabIndex == _PageTabs.display.index) {
      final state = _habitsTabKey.currentState;
      if (state != null) {
        return await state.onWillPop();
      }
    }
    return true;
  }

  void _handleDismissIntent() {
    if (_currentTabIndex != _PageTabs.display.index) return;
    _habitsTabKey.currentState?.handleDismissIntent();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final uiLayoutType = computeLayoutType(
      width: size.width,
      height: size.height,
    );
    final isWideLayout = uiLayoutType == UiLayoutType.l;
    final bottomNavHeight = isWideLayout ? kBottomNavigationBarHeight : 80.0;

    final tabBody = PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      itemCount: _PageTabs.values.length,
      itemBuilder: (context, index) {
        if (index == _PageTabs.display.index) {
          return HabitsTabPage(
            key: _habitsTabKey,
            onBottomNavVisibilityChanged: _handleBottomNavVisibilityChanged,
          );
        }
        if (index == _PageTabs.today.index) {
          return TodayTabPage(
            key: _todayTabKey,
            bottomNavigationHeight: bottomNavHeight,
            onBottomNavVisibilityChanged: _handleBottomNavVisibilityChanged,
          );
        }
        return null;
      },
      onPageChanged: (index) {
        setState(() {
          _currentTabIndex = index;
          _isBottomNavVisible = true;
          final newLaunchEntry = AppEntrys.getFromDBCode(_currentTabIndex + 1);
          if (newLaunchEntry != null) {
            context
                .maybeRead<ProfileViewModel>()
                ?.getHandler<AppLaunchEntryProfileHandler>()
                ?.set(newLaunchEntry);
          }
        });
      },
    );

    final naviBarBody = L10nBuilder(
      builder: (context, l10n) {
        final destinations = [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n?.habitDisplay_tab_habits_label ?? 'Habits',
          ),
          NavigationDestination(
            icon: const Icon(MdiIcons.calendarTodayOutline),
            selectedIcon: const Icon(MdiIcons.calendarToday),
            label: l10n?.habitDisplay_tab_today_label ?? 'Today',
          ),
        ];
        return NavigationBar(
          height: bottomNavHeight,
          selectedIndex: _currentTabIndex,
          labelBehavior: isWideLayout
              ? NavigationDestinationLabelBehavior.alwaysHide
              : NavigationDestinationLabelBehavior.alwaysShow,
          destinations: destinations,
          onDestinationSelected: (index) => setState(() {
            _pageController.jumpToPage(index);
            _isBottomNavVisible = true;
          }),
        );
      },
    );

    final bottomNavigationBar = AnimatedSlide(
      duration: _bottomNavAnimationDuration,
      curve: Curves.easeOut,
      offset: _isBottomNavVisible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: _bottomNavAnimationDuration,
        opacity: _isBottomNavVisible ? 1 : 0,
        child: naviBarBody,
      ),
    );

    final body = Stack(
      children: [
        Positioned.fill(
          child: AnimatedPadding(
            duration: _bottomNavAnimationDuration,
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: _isBottomNavVisible ? bottomNavHeight : 0,
            ),
            child: tabBody,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: bottomNavigationBar,
          ),
        ),
      ],
    );

    return ColorfulNavibar(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (await _handleWillPop() && context.mounted) {
            Navigator.of(context).popOrExit(result);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Actions(
            actions: {
              DismissIntent: CallbackAction(
                onInvoke: (intent) {
                  _handleDismissIntent();
                  return null;
                },
              ),
            },
            child: body,
          ),
          floatingActionButton: _buildFloatingActionButton(bottomNavHeight),
        ),
      ),
    );
  }
}
