// Copyright 2026 Fries_I23
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
import 'package:flutter/services.dart';

/// A generic text field with a dropdown menu overlay, similar to [DropdownMenu]
/// but with full control over the trigger widget layout and menu children.
///
/// Features:
/// - Custom trigger widget via [builder] (e.g. [ListTile] + [TextField]).
/// - Menu opens on text input and closes on ESC/outside tap.
/// - Filtering via [menuChildrenBuilder] callback.
/// - Trailing icon toggle (e.g. search ↔ close) via [MenuController].
///
/// The caller should use [MenuController.open] in the [TextField.onTap]
/// callback to open the menu on focus.
class FilterableMenuField<T> extends StatefulWidget {
  /// The display text shown in the text field.
  ///
  /// When this changes (e.g. after a selection), the text field's content
  /// is updated and the filter query is reset.
  final String label;

  /// Builds the trigger widget.
  ///
  /// Parameters:
  /// - [TextEditingController]: the text field controller, initialized with
  ///   [label].
  /// - [FocusNode]: attach to [TextField.focusNode].
  /// - [MenuController]: use [MenuController.isOpen] / [MenuController.open]
  ///   / [MenuController.close] to manage the trailing icon and menu toggle.
  ///
  /// The builder should create a [TextField.onTap] that calls
  /// `menuController.open()` to open the menu on tap.
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    MenuController menuController,
  )
  builder;

  /// Builds the menu children based on the current filter [query].
  ///
  /// [highlightIndex] is the 0-based index of the keyboard-highlighted item,
  /// or -1 when no item is highlighted. The caller should apply a highlighted
  /// style (e.g. via [MenuItemButton.style]) to the corresponding item.
  final List<Widget> Function(String query, int highlightIndex)
  menuChildrenBuilder;

  /// Called when the highlighted menu item is activated (e.g. via Enter key).
  ///
  /// The caller receives the [highlightIndex] and current [query], and should
  /// map the index to the correct value, then call [onSelected].
  final void Function(int highlightIndex, String query)? onHighlightActivated;

  /// An optional external [MenuController] for programmatic control.
  final MenuController? menuController;

  /// Custom [MenuStyle] for the dropdown menu.
  final MenuStyle? menuStyle;

  /// [Clip] behavior for the menu panel.
  ///
  /// Defaults to [Clip.antiAlias] so that [MenuStyle.shape] rounded corners
  /// render correctly during open/close animation.
  final Clip clipBehavior;

  /// Offset applied to the menu's alignment relative to the anchor widget.
  ///
  /// Passed through to [MenuAnchor.alignmentOffset].
  final Offset alignmentOffset;

  const FilterableMenuField({
    super.key,
    required this.label,
    required this.builder,
    required this.menuChildrenBuilder,
    this.menuController,
    this.menuStyle,
    this.clipBehavior = Clip.antiAlias,
    this.onHighlightActivated,
    this.alignmentOffset = Offset.zero,
  });

  @override
  State<FilterableMenuField<T>> createState() => _FilterableMenuFieldState<T>();
}

class _FilterableMenuFieldState<T> extends State<FilterableMenuField<T>> {
  late final MenuController _menuController;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final FocusNode _tileFocusNode;
  final ValueNotifier<bool> _isMenuOpen = ValueNotifier(false);
  String _query = '';
  bool _isUpdatingText = false;
  int _highlightIndex = -1;

  MenuController get _effectiveMenuController =>
      widget.menuController ?? _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = MenuController();
    _textController = TextEditingController(text: widget.label);
    _textController.addListener(_onTextChanged);
    _focusNode = FocusNode(onKeyEvent: _handleMenuNavigation);
    _tileFocusNode = FocusNode(onKeyEvent: _handleMenuNavigation);
  }

  @override
  void didUpdateWidget(covariant FilterableMenuField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.label != _textController.text) {
      _isUpdatingText = true;
      _textController.text = widget.label;
      _query = '';
      _highlightIndex = -1;
      _isUpdatingText = false;
    }
  }

  @override
  void dispose() {
    _isMenuOpen.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    _tileFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isUpdatingText) return;
    final text = _textController.text;
    if (_query != text) {
      setState(() {
        _query = text;
        _highlightIndex = -1;
      });
      if (!_isMenuOpen.value) {
        _effectiveMenuController.open();
      }
    }
  }

  KeyEventResult _handleMenuNavigation(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !_isMenuOpen.value) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final forward = key == LogicalKeyboardKey.arrowDown;
      setState(() => forward ? _highlightIndex++ : _highlightIndex--);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (_highlightIndex >= 0) {
        widget.onHighlightActivated?.call(_highlightIndex, _query);
        _effectiveMenuController.close();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _effectiveMenuController,
      alignmentOffset: widget.alignmentOffset,
      clipBehavior: widget.clipBehavior,
      onOpen: () {
        _isMenuOpen.value = true;
        _highlightIndex = -1;
      },
      onClose: () => _isMenuOpen.value = false,
      childFocusNode: _focusNode,
      menuChildren: widget.menuChildrenBuilder(_query, _highlightIndex),
      style: widget.menuStyle,
      builder: (_, controller, _) => Focus(
        focusNode: _tileFocusNode,
        child: widget.builder(context, _textController, _focusNode, controller),
      ),
    );
  }
}
