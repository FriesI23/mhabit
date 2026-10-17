import 'navigation_shell_form.dart';

/// Remembers only an explicit collapse for the lifetime of a navigation shell.
///
/// Expansion controllers keep their own transient presentation. Automatic form
/// changes must not call [recordExpanded].
class SidebarCollapseMemory {
  bool _collapsed = false;

  /// Resolves a new form without retaining an explicit expansion.
  bool expandedFor(NavigationShellForm form) =>
      !_collapsed && form == NavigationShellForm.expandedSide;

  /// Records a user action; opening the sidebar clears the collapse memory.
  void recordExpanded(bool expanded) => _collapsed = !expanded;
}
