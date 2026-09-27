// Copyright 2026 Fries_I23
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

import 'package:flutter/widgets.dart';
import 'package:mhabit_adaptive_ui/mhabit_adaptive_ui.dart';

extension AdaptiveNavigationContext on BuildContext {
  bool get hasCollapsedAppleSidebar => _appleSidebarExpanded == false;

  bool get hasExpandedAppleSidebar =>
      switch ((AdaptiveNavScope.maybeOf(this)?.form, _appleSidebarExpanded)) {
        (NavigationShellForm.compact, _) => false,
        (_, true) => true,
        _ => false,
      };

  bool get showsAppleAuxiliaryActionsInAppBar {
    final compact =
        AdaptiveNavScope.maybeOf(this)?.form == NavigationShellForm.compact ||
        WindowSize.of(this).width == WindowSizeClass.compact;
    return compact || hasCollapsedAppleSidebar;
  }

  bool? get _appleSidebarExpanded => switch (AdaptiveStyle.of(this)) {
    AdaptiveStyle.material => null,
    AdaptiveStyle.apple => CupertinoSidebarPresentationScope.maybeOf(
      this,
    )?.expanded,
  };
}
