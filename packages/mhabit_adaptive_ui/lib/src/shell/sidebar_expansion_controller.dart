import 'package:flutter_adaptive_sidebar/flutter_adaptive_sidebar.dart';

import 'navigation_shell_form.dart';
import 'sidebar_collapse_memory.dart';

/// Sidebar controller with form defaults and shared collapse memory.
///
/// Preserves the parent controller's selection, width, and notification behavior.
/// [updateForm] applies automatic expansion without recording a user action.
class SidebarExpansionController extends AdaptiveNavigationController {
  final SidebarCollapseMemory _localMemory = SidebarCollapseMemory();
  SidebarCollapseMemory? _memory;
  NavigationShellForm? _form;

  @override
  set expanded(bool value) {
    if (value == super.expanded) return;
    (_memory ?? _localMemory).recordExpanded(value);
    super.expanded = value;
  }

  /// Applies the default for a changed form or memory source.
  ///
  /// Null [collapseMemory] uses local memory for standalone renderers. Compact
  /// forms leave the controller alone until side navigation is shown again.
  void updateForm(
    NavigationShellForm form, {
    SidebarCollapseMemory? collapseMemory,
  }) {
    final memory = collapseMemory ?? _localMemory;
    if (form == _form && memory == _memory) return;
    _form = form;
    _memory = memory;
    if (form == NavigationShellForm.compact) return;

    // Call the parent setter so automatic changes notify the sidebar normally
    // while bypassing the user-preference setter above.
    super.expanded = memory.expandedFor(form);
  }
}
