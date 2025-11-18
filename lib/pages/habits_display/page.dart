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

import '../../common/utils.dart';
import '../../extensions/navigator_extensions.dart';
import '../../widgets/widgets.dart';
import 'page_habits.dart';
import 'page_today.dart';
import 'providers.dart';

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
  static const Duration _bottomNavAnimationDuration =
      Duration(milliseconds: 250);

  int _currentTabIndex = 0;
  bool _isBottomNavVisible = true;
  bool _fabRebuildPending = false;

  final GlobalKey<HabitsTabPageState> _habitsTabKey =
      GlobalKey<HabitsTabPageState>();

  void _handleBottomNavVisibilityChanged(bool visible) {
    if (_isBottomNavVisible == visible) return;
    setState(() => _isBottomNavVisible = visible);
  }

  Widget? _buildFloatingActionButton(double bottomNavHeight) {
    if (_currentTabIndex != 0) return null;
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
    if (_currentTabIndex == 0) {
      final state = _habitsTabKey.currentState;
      if (state != null) {
        return await state.onWillPop();
      }
    }
    return true;
  }

  void _handleDismissIntent() {
    if (_currentTabIndex != 0) return;
    _habitsTabKey.currentState?.handleDismissIntent();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final uiLayoutType =
        computeLayoutType(width: size.width, height: size.height);
    final isWideLayout = uiLayoutType == UiLayoutType.l;
    final bottomNavHeight = isWideLayout ? kBottomNavigationBarHeight : 80.0;

    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: 'Habits',
      ),
      NavigationDestination(
        icon: Icon(Icons.more_horiz_outlined),
        selectedIcon: Icon(Icons.more_horiz),
        label: 'More',
      ),
    ];

    final tabs = <Widget>[
      HabitsTabPage(
        key: _habitsTabKey,
        onBottomNavVisibilityChanged: _handleBottomNavVisibilityChanged,
      ),
      const TodayTabPage(),
    ];

    final tabBody = IndexedStack(
      index: _currentTabIndex,
      children: tabs,
    );

    final bottomNavigationBar = AnimatedSlide(
      duration: _bottomNavAnimationDuration,
      curve: Curves.easeOut,
      offset: _isBottomNavVisible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: _bottomNavAnimationDuration,
        opacity: _isBottomNavVisible ? 1 : 0,
        child: NavigationBar(
          height: bottomNavHeight,
          selectedIndex: _currentTabIndex,
          labelBehavior: isWideLayout
              ? NavigationDestinationLabelBehavior.alwaysHide
              : NavigationDestinationLabelBehavior.alwaysShow,
          destinations: destinations,
          onDestinationSelected: (index) {
            setState(() {
              _currentTabIndex = index;
              _isBottomNavVisible = true;
            });
          },
        ),
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
              context: context, removeTop: true, child: bottomNavigationBar),
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
          body: Actions(actions: {
            DismissIntent: CallbackAction(onInvoke: (intent) {
              _handleDismissIntent();
              return null;
            })
          }, child: body),
          floatingActionButton: _buildFloatingActionButton(bottomNavHeight),
        ),
      ),
    );
  }
}
