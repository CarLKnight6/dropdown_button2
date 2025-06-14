/*
 * Created by AHMED ELSAYED on 30 Nov 2021.
 * email: ahmedelsaayid@gmail.com
 * Edits made on original source code by Flutter.
 * Copyright 2014 The Flutter Authors. All rights reserved.
*/

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'seperated_sliver_child_builder_delegate.dart';

part 'button_style_data.dart';
part 'dropdown_style_data.dart';
part 'dropdown_route.dart';
part 'dropdown_menu.dart';
part 'dropdown_menu_item.dart';
part 'dropdown_menu_separators.dart';
part 'enums.dart';
part 'utils.dart';

const Duration _kDropdownMenuDuration = Duration(milliseconds: 300);
const double _kMenuItemHeight = kMinInteractiveDimension;
const double _kDenseButtonHeight = 24.0;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 16.0);
const EdgeInsetsGeometry _kAlignedButtonPadding =
    EdgeInsetsDirectional.only(start: 16.0, end: 4.0);
const EdgeInsets _kUnalignedButtonPadding = EdgeInsets.zero;

/// A builder to customize the selected menu item.
typedef SelectedMenuItemBuilder = Widget Function(
    BuildContext context, Widget child);

/// A builder to customize the dropdown menu.
typedef DropdownBuilder = Widget Function(BuildContext context, Widget child);

/// Signature for the callback that's called when when the dropdown menu opens or closes.
typedef OnMenuStateChangeFn = void Function(bool isOpen);

/// Signature for the callback for the match function used for searchable dropdowns.
typedef SearchMatchFn<T> = bool Function(
    DropdownItem<T> item, String searchValue);

/// A Material Design button for selecting from a list of items.
///
/// A dropdown button lets the user select from a number of items. The button
/// shows the currently selected item as well as an arrow that opens a menu for
/// selecting another item.
///
/// One ancestor must be a [Material] widget and typically this is
/// provided by the app's [Scaffold].
///
/// The type `T` is the type of the value that each dropdown item represents.
/// All the entries in a given menu must represent values with consistent types.
/// Typically, an enum is used. Each [DropdownItem] in [items] must be
/// specialized with that same type argument.
///
/// The [onChanged] callback should update a state variable that defines the
/// dropdown's value. It should also call [State.setState] to rebuild the
/// dropdown with the new value.
///
/// If the [onChanged] callback is null or the list of [items] is null
/// then the dropdown button will be disabled, i.e. its arrow will be
/// displayed in grey and it will not respond to input. A disabled button
/// will display the [disabledHint] widget if it is non-null. However, if
/// [disabledHint] is null and [hint] is non-null, the [hint] widget will
/// instead be displayed.
///
/// See also:
///
///  * [DropdownButtonFormField2], which integrates with the [Form] widget.
///  * [DropdownItem], the class used to represent the [items].
///  * [DropdownButtonHideUnderline], which prevents its descendant dropdown buttons
///    from displaying their underlines.
///  * [ElevatedButton], [TextButton], ordinary buttons that trigger a single action.
///  * <https://material.io/design/components/menus.html#dropdown-menu>
class DropdownButton2<T> extends StatefulWidget {
  /// Creates a DropdownButton2.
  /// It's customizable DropdownButton with steady dropdown menu and many other features.
  ///
  /// The [items] must have distinct values. If [valueListenable] isn't null then its value
  /// must be equal to one of the [DropdownItem] values. If [multiValueListenable] isn't null
  /// then its value must be equal to one or more of the [DropdownItem] values.
  /// If [items] or [onChanged] is null, the button will be disabled, the down arrow
  /// will be greyed out.
  ///
  /// If no [DropdownItem] is selected and the button is enabled, [hint] will be displayed
  /// if it is non-null.
  ///
  /// If no [DropdownItem] is selected and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [hint] will be displayed
  /// if it is non-null.
  const DropdownButton2({
    super.key,
    required this.items,
    this.selectedItemBuilder,
    this.valueListenable,
    this.multiValueListenable,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.onMenuStateChange,
    this.style,
    this.underline,
    this.isDense = false,
    this.isExpanded = false,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.buttonStyleData,
    this.iconStyleData = const IconStyleData(),
    this.dropdownStyleData = const DropdownStyleData(),
    this.menuItemStyleData = const MenuItemStyleData(),
    this.dropdownSearchData,
    this.dropdownSeparator,
    this.customButton,
    this.openWithLongPress = false,
    this.barrierDismissible = true,
    this.barrierCoversButton = true,
    this.barrierColor,
    this.barrierLabel,
    this.openDropdownListenable,
    // When adding new arguments, consider adding similar arguments to
    // DropdownButtonFormField.
  })  : assert(
          valueListenable == null || multiValueListenable == null,
          'Only one of valueListenable or multiValueListenable can be used.',
        ),
        _inputDecoration = null,
        _isEmpty = false,
        _hasError = false;

  const DropdownButton2._formField({
    super.key,
    required this.items,
    required this.selectedItemBuilder,
    required this.valueListenable,
    required this.multiValueListenable,
    required this.hint,
    required this.disabledHint,
    required this.onChanged,
    required this.onMenuStateChange,
    required this.style,
    required this.isDense,
    required this.isExpanded,
    required this.focusNode,
    required this.autofocus,
    required this.enableFeedback,
    required this.alignment,
    required this.buttonStyleData,
    required this.iconStyleData,
    required this.dropdownStyleData,
    required this.menuItemStyleData,
    required this.dropdownSearchData,
    required this.dropdownSeparator,
    required this.customButton,
    required this.openWithLongPress,
    required this.barrierDismissible,
    required this.barrierCoversButton,
    required this.barrierColor,
    required this.barrierLabel,
    required this.openDropdownListenable,
    required InputDecoration inputDecoration,
    required bool isEmpty,
    required bool hasError,
  })  : underline = null,
        _inputDecoration = inputDecoration,
        _isEmpty = isEmpty,
        _hasError = hasError;

  /// The list of items the user can select.
  ///
  /// If the [onChanged] callback is null or the list of items is null
  /// then the dropdown button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input.
  final List<DropdownItem<T>>? items;

  /// A builder to customize the dropdown buttons corresponding to the
  /// [DropdownItem]s in [items].
  ///
  /// When a [DropdownItem] is selected, the widget that will be displayed
  /// from the list corresponds to the [DropdownItem] of the same index
  /// in [items].
  ///
  /// {@tool dartpad}
  /// This sample shows a [DropdownButton] with a button with [Text] that
  /// corresponds to but is unique from [DropdownItem].
  ///
  /// ** See code in examples/api/lib/material/dropdown/dropdown_button.selected_item_builder.0.dart **
  /// {@end-tool}
  ///
  /// If this callback is null, the [DropdownItem] from [items]
  /// that matches the selected [DropdownItem]'s value will be displayed.
  final DropdownButtonBuilder? selectedItemBuilder;

  /// A [ValueListenable] that represents the value of the currently selected [DropdownItem].
  /// It holds a value of type `T?`, where `T` represents the type of [DropdownItem]'s value.
  ///
  /// If the value is null and the button is enabled, [hint] will be displayed
  /// if it is non-null.
  ///
  /// If the value is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [hint] will be displayed
  /// if it is non-null.
  final ValueListenable<T?>? valueListenable;

  /// A [ValueListenable] that represents a list of the currently selected [DropdownItem]s.
  /// It holds a list of type `List<T>`, where `T` represents the type of [DropdownItem]'s value.
  ///
  /// If the list is empty and the button is enabled, [hint] will be displayed
  /// if it is non-null.
  ///
  /// If the list is empty and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [hint] will be displayed
  /// if it is non-null.
  final ValueListenable<List<T>>? multiValueListenable;

  /// A placeholder widget that is displayed by the dropdown button.
  ///
  /// If no [DropdownItem] is selected and the dropdown is enabled ([items] and [onChanged] are non-null),
  /// this widget is displayed as a placeholder for the dropdown button's value.
  ///
  /// If no [DropdownItem] is selected and the dropdown is disabled and [disabledHint] is null,
  /// this widget is used as the placeholder.
  final Widget? hint;

  /// A preferred placeholder widget that is displayed when the dropdown is disabled.
  ///
  /// If no [DropdownItem] is selected and the dropdown is disabled ([items] or [onChanged] is null),
  /// this widget is displayed as a placeholder for the dropdown button's value.
  final Widget? disabledHint;

  /// {@template flutter.material.dropdownButton.onChanged}
  /// Called when the user selects an item.
  ///
  /// If the [onChanged] callback is null or the list of [DropdownButton2.items]
  /// is null then the dropdown button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input. A disabled button
  /// will display the [DropdownButton2.disabledHint] widget if it is non-null.
  /// If [DropdownButton2.disabledHint] is also null but [DropdownButton2.hint] is
  /// non-null, [DropdownButton2.hint] will instead be displayed.
  /// {@endtemplate}
  final ValueChanged<T?>? onChanged;

  /// Called when the dropdown menu opens or closes.
  final OnMenuStateChangeFn? onMenuStateChange;

  /// The text style to use for text in the dropdown button and the dropdown
  /// menu that appears when you tap the button.
  ///
  /// To use a separate text style for selected item when it's displayed within
  /// the dropdown button, consider using [selectedItemBuilder].
  ///
  /// {@tool dartpad}
  /// This sample shows a `DropdownButton` with a dropdown button text style
  /// that is different than its menu items.
  ///
  /// ** See code in examples/api/lib/material/dropdown/dropdown_button.style.0.dart **
  /// {@end-tool}
  ///
  /// Defaults to the [TextTheme.titleMedium] value of the current
  /// [ThemeData.textTheme] of the current [Theme].
  final TextStyle? style;

  /// The widget to use for drawing the drop-down button's underline.
  ///
  /// Defaults to a 0.0 width bottom border with color 0xFFBDBDBD.
  final Widget? underline;

  /// Reduce the button's height.
  ///
  /// By default this button's height is the same as its menu items' heights.
  /// If isDense is true, the button's height is reduced by about half. This
  /// can be useful when the button is embedded in a container that adds
  /// its own decorations, like [InputDecorator].
  final bool isDense;

  /// Set the dropdown's inner contents to horizontally fill its parent.
  ///
  /// By default this button's inner width is the minimum size of its contents.
  /// If [isExpanded] is true, the inner width is expanded to fill its
  /// surrounding container.
  final bool isExpanded;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// By default, platform-specific feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  /// Defines how the hint or the selected item is positioned within the button.
  ///
  /// Defaults to [AlignmentDirectional.centerStart].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// Used to configure the theme of the button
  final ButtonStyleData? buttonStyleData;

  /// Used to configure the theme of the button's icon
  final IconStyleData iconStyleData;

  /// Used to configure the theme of the dropdown menu
  final DropdownStyleData dropdownStyleData;

  /// Used to configure the theme of the dropdown menu items
  final MenuItemStyleData menuItemStyleData;

  /// Used to configure searchable dropdowns
  final DropdownSearchData<T>? dropdownSearchData;

  /// Adds separator widget to the dropdown menu.
  ///
  /// Defaults to null.
  final DropdownSeparator<T>? dropdownSeparator;

  /// Uses custom widget like icon,image,etc.. instead of the default button
  final Widget? customButton;

  /// Opens the dropdown menu on long-pressing instead of tapping
  final bool openWithLongPress;

  /// Whether you can dismiss this route by tapping the modal barrier.
  final bool barrierDismissible;

  /// Specifies whether the modal barrier should cover the dropdown button or not.
  ///
  /// Defaults to true.
  final bool barrierCoversButton;

  /// The color to use for the modal barrier. If this is null, the barrier will
  /// be transparent.
  final Color? barrierColor;

  /// The semantic label used for a dismissible barrier.
  ///
  /// If the barrier is dismissible, this label will be read out if
  /// accessibility tools (like VoiceOver on iOS) focus on the barrier.
  final String? barrierLabel;

  /// A [Listenable] that can be used to programmatically open the dropdown menu.
  ///
  /// The [openDropdownListenable] allows you to manually open the dropdown by modifying its value.
  ///
  /// For example:
  /// ```dart
  /// final openDropdownListenable = ValueNotifier<Object?>(null);
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Column(
  ///     children:[
  ///       DropdownButton2<String>(
  ///         // Other properties...
  ///         openDropdownListenable: openDropdownListenable,
  ///       );
  ///       // Open the dropdown programmatically, like when another button is pressed:
  ///       ElevatedButton(
  ///         onTap: () => openDropdownListenable.value = Object(),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// ```
  final Listenable? openDropdownListenable;

  final InputDecoration? _inputDecoration;

  final bool _isEmpty;

  final bool _hasError;

  @override
  State<DropdownButton2<T>> createState() => _DropdownButton2State<T>();
}

class _DropdownButton2State<T> extends State<DropdownButton2<T>>
    with WidgetsBindingObserver {
  int? _selectedIndex;
  _DropdownRoute<T>? _dropdownRoute;
  Orientation? _lastOrientation;
  FocusNode? _internalNode;

  ButtonStyleData? get _buttonStyle => widget.buttonStyleData;

  IconStyleData get _iconStyle => widget.iconStyleData;

  DropdownStyleData get _dropdownStyle => widget.dropdownStyleData;

  MenuItemStyleData get _menuItemStyle => widget.menuItemStyleData;

  DropdownSearchData<T>? get _searchData => widget.dropdownSearchData;

  FocusNode get _focusNode => widget.focusNode ?? _internalNode!;

  late Map<Type, Action<Intent>> _actionMap;
  bool _isHovering = false;
  bool _isFocused = false;

  // Using ValueNotifier for tracking when menu is open/close to update the button icon.
  final ValueNotifier<bool> _isMenuOpen = ValueNotifier<bool>(false);

  final _buttonRectKey = GlobalKey();

  // Using ValueNotifier for the Rect of DropdownButton so the dropdown menu listen and
  // update its position if DropdownButton's position has changed, as when keyboard open.
  final ValueNotifier<Rect?> _buttonRect = ValueNotifier<Rect?>(null);

  // Only used if needed to create _internalNode.
  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateSelectedIndex();
    widget.valueListenable?.addListener(_updateSelectedIndex);
    widget.multiValueListenable?.addListener(_updateSelectedIndex);
    widget.openDropdownListenable?.addListener(_programmaticallyOpenDropdown);
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _handleTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => _handleTap(),
      ),
    };
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.valueListenable?.removeListener(_updateSelectedIndex);
    widget.multiValueListenable?.removeListener(_updateSelectedIndex);
    widget.openDropdownListenable
        ?.removeListener(_programmaticallyOpenDropdown);
    _removeDropdownRoute();
    _focusNode.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    _isMenuOpen.dispose();
    _buttonRect.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  T? get _currentValue {
    if (widget.valueListenable != null) {
      return widget.valueListenable!.value;
    }
    if (widget.multiValueListenable != null) {
      //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
      return widget.multiValueListenable!.value.lastOrNull;
    }
    return null;
  }

  void _removeDropdownRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
    _lastOrientation = null;
  }

  @override
  void didUpdateWidget(DropdownButton2<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (_internalNode != null && widget.focusNode != null) {
        _internalNode!.removeListener(_handleFocusChanged);
      }

      if (widget.focusNode == null) {
        _internalNode ??= _createFocusNode();
      }
      _isFocused = _focusNode.hasFocus;
      _focusNode.addListener(_handleFocusChanged);
    }

    if (widget.valueListenable != oldWidget.valueListenable ||
        widget.multiValueListenable != oldWidget.multiValueListenable) {
      _updateSelectedIndex();
      oldWidget.valueListenable?.removeListener(_updateSelectedIndex);
      oldWidget.multiValueListenable?.removeListener(_updateSelectedIndex);
      widget.valueListenable?.addListener(_updateSelectedIndex);
      widget.multiValueListenable?.addListener(_updateSelectedIndex);
    }

    if (widget.openDropdownListenable != oldWidget.openDropdownListenable) {
      oldWidget.openDropdownListenable
          ?.removeListener(_programmaticallyOpenDropdown);
      widget.openDropdownListenable?.addListener(_programmaticallyOpenDropdown);
    }
  }

  void _updateSelectedIndex() {
    if (widget.items == null ||
        widget.items!.isEmpty ||
        (_currentValue == null &&
            widget.items!
                .where((DropdownItem<T> item) =>
                    item.enabled && item.value == _currentValue)
                .isEmpty)) {
      _selectedIndex = null;
      return;
    }

    for (int itemIndex = 0; itemIndex < widget.items!.length; itemIndex++) {
      if (widget.items![itemIndex].value == _currentValue) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  void _programmaticallyOpenDropdown() {
    if (_enabled && !_isMenuOpen.value) {
      _handleTap();
    }
  }

  @override
  void didChangeMetrics() {
    //This fix the bug of calling didChangeMetrics() on iOS when app starts
    if (_buttonRect.value == null) {
      return;
    }
    _buttonRect.value = _getButtonRect();
  }

  TextStyle? get _textStyle =>
      widget.style ?? Theme.of(context).textTheme.titleMedium;

  Rect _getButtonRect() {
    // InputDecorator is a parent of _buttonRect (to avoid the dropdown menu opening under the button's error/helper),
    // so we need to consider its padding in additional to _buttonRect.
    final EdgeInsets contentPadding =
        _getInputDecorationPadding() ?? EdgeInsets.zero;
    final NavigatorState navigator = Navigator.of(context,
        rootNavigator:
            _dropdownStyle.isFullScreen ?? _dropdownStyle.useRootNavigator);

    final RenderBox itemBox =
        _buttonRectKey.currentContext!.findRenderObject()! as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero,
            ancestor: navigator.context.findRenderObject()) &
        itemBox.size;

    final denseRect = contentPadding.inflateRect(itemRect);

    if (widget._inputDecoration?.isDense == false) {
      final extraHeight = kMinInteractiveDimension - denseRect.height;
      if (extraHeight > 0) {
        return (contentPadding +
                EdgeInsets.symmetric(vertical: extraHeight / 2))
            .inflateRect(itemRect);
      }
    }

    return denseRect;
  }

  EdgeInsets? _getInputDecorationPadding() {
    // Return the contentPadding only if inputDecoration is defined.
    if (widget._inputDecoration case final decoration?) {
      final TextDirection? textDirection = Directionality.maybeOf(context);
      // Use inputDecorationTheme.visualDensity when added (https://github.com/flutter/flutter/issues/166201#issuecomment-2774622584)
      final Offset densityOffset =
          Theme.of(context).visualDensity.baseSizeAdjustment;
      final EdgeInsets? contentPadding = (decoration.contentPadding ??
              Theme.of(context).inputDecorationTheme.contentPadding)
          ?.resolve(textDirection);
      return contentPadding?.copyWith(
        top: math.max(0, contentPadding.top + densityOffset.dy / 2),
        bottom: math.max(0, contentPadding.bottom + densityOffset.dy / 2),
      );
    } else {
      return null;
    }
  }

  Set<WidgetState> _materialState(InputDecoration decoration) => <WidgetState>{
        if (!decoration.enabled) WidgetState.disabled,
        if (_isFocused) WidgetState.focused,
        if (_isHovering) WidgetState.hovered,
        if (widget._hasError) WidgetState.error,
      };

  BorderRadius? _getInputDecorationBorderRadius(InputDecoration decoration) {
    InputBorder? border;
    if (!decoration.enabled) {
      border =
          widget._hasError ? decoration.errorBorder : decoration.disabledBorder;
    } else if (_isFocused) {
      border = widget._hasError
          ? decoration.focusedErrorBorder
          : decoration.focusedBorder;
    } else {
      border =
          widget._hasError ? decoration.errorBorder : decoration.enabledBorder;
    }
    border ??= WidgetStateProperty.resolveAs(
        decoration.border, _materialState(decoration));

    if (border is OutlineInputBorder) {
      return border.borderRadius;
    }
    return null;
  }

  EdgeInsetsGeometry _buttonAdditionalHPadding() {
    final TextDirection? textDirection = Directionality.maybeOf(context);

    final menuItemPadding =
        _menuItemStyle.padding?.resolve(textDirection) ?? _kMenuItemPadding;
    final removeItemHPadding = _menuItemStyle.useDecorationHorizontalPadding &&
        _getInputDecorationPadding() != null;
    final effectiveMenuItemPadding = menuItemPadding.copyWith(
      left: removeItemHPadding ? 0 : null,
      right: removeItemHPadding ? 0 : null,
    );

    return effectiveMenuItemPadding
        .add(_dropdownStyle.padding ?? EdgeInsets.zero)
        .add(_dropdownStyle.scrollPadding ?? EdgeInsets.zero)
        .resolve(textDirection)
        .copyWith(top: 0, bottom: 0);
  }

  void _handleTap() {
    final NavigatorState navigator = Navigator.of(context,
        rootNavigator:
            _dropdownStyle.isFullScreen ?? _dropdownStyle.useRootNavigator);
    final TextDirection? textDirection = Directionality.maybeOf(context);

    final items = widget.items!;
    final separator = widget.dropdownSeparator;
    _buttonRect.value = _getButtonRect();

    assert(_dropdownRoute == null);
    _dropdownRoute = _DropdownRoute<T>(
      items: items,
      buttonRect: _buttonRect,
      buttonBorderRadius: widget._inputDecoration != null
          ? _getInputDecorationBorderRadius(widget._inputDecoration!)
          : _getButtonBorderRadius(context),
      selectedIndex: _selectedIndex ?? 0,
      isNoSelectedItem: _selectedIndex == null,
      onChanged: widget.onChanged,
      capturedThemes:
          InheritedTheme.capture(from: context, to: navigator.context),
      style: _textStyle!,
      barrierDismissible: widget.barrierDismissible,
      barrierColor: widget.barrierColor,
      barrierLabel: widget.barrierLabel ??
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierCoversButton: widget.barrierCoversButton,
      parentFocusNode: _focusNode,
      enableFeedback: widget.enableFeedback ?? true,
      textDirection: textDirection,
      dropdownStyle: _dropdownStyle,
      menuItemStyle: _menuItemStyle,
      inputDecorationPadding: _getInputDecorationPadding(),
      searchData: _searchData,
      dropdownSeparator: separator,
    );

    _isMenuOpen.value = true;
    _focusNode.requestFocus();
    // This is a temporary fix for the "dropdown menu steal the focus from the
    // underlying button" issue, until share focus is fixed in flutter (#106923).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dropdownRoute?._childNode.requestFocus();
    });
    navigator
        .push(_dropdownRoute!)
        .then<void>((_DropdownRouteResult<T>? newValue) {
      _removeDropdownRoute();
      _isMenuOpen.value = false;
      widget.onMenuStateChange?.call(false);
    });

    widget.onMenuStateChange?.call(true);
  }

  // When isDense is true, reduce the height of this button from _kMenuItemHeight to
  // _kDenseButtonHeight, but don't make it smaller than the text that it contains.
  // Similarly, we don't reduce the height of the button so much that its icon
  // would be clipped.
  double get _denseButtonHeight {
    final double fontSize = _textStyle!.fontSize ??
        Theme.of(context).textTheme.titleMedium!.fontSize!;
    final double lineHeight = _textStyle!.height ??
        Theme.of(context).textTheme.titleMedium!.height ??
        1.0;
    final double scaledFontSize =
        MediaQuery.textScalerOf(context).scale(fontSize * lineHeight);
    return math.max(
        scaledFontSize, math.max(_iconStyle.iconSize, _kDenseButtonHeight));
  }

  Color get _iconColor {
    // These colors are not defined in the Material Design spec.
    final Brightness brightness = Theme.of(context).brightness;
    if (_enabled) {
      return _iconStyle.iconEnabledColor ??
          switch (brightness) {
            Brightness.light => Colors.grey.shade700,
            Brightness.dark => Colors.white70,
          };
    } else {
      return _iconStyle.iconDisabledColor ??
          switch (brightness) {
            Brightness.light => Colors.grey.shade400,
            Brightness.dark => Colors.white10,
          };
    }
  }

  bool get _enabled =>
      widget.items != null &&
      widget.items!.isNotEmpty &&
      widget.onChanged != null;

  Orientation _getOrientation(BuildContext context) {
    Orientation? result = MediaQuery.maybeOrientationOf(context);
    if (result == null) {
      // If there's no MediaQuery, then use the current FlutterView to determine
      // orientation.
      final Size size = View.of(context).physicalSize;
      result = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
    }
    return result;
  }

  BorderRadius? _getButtonBorderRadius(BuildContext context) {
    final buttonRadius = _buttonStyle?.decoration?.borderRadius ??
        _buttonStyle?.foregroundDecoration?.borderRadius;
    if (buttonRadius != null) {
      return buttonRadius.resolve(Directionality.maybeOf(context));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final Orientation newOrientation = _getOrientation(context);
    _lastOrientation ??= newOrientation;
    if (newOrientation != _lastOrientation) {
      _removeDropdownRoute();
      _lastOrientation = newOrientation;
    }

    // The width of the button and the menu are defined by the widest
    // item and the width of the hint.
    // We should explicitly type the items list to be a list of <Widget>,
    // otherwise, no explicit type adding items maybe trigger a crash/failure
    // when hint and selectedItemBuilder are provided.
    final List<Widget> buttonItems = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.of(widget.items!) : <Widget>[])
        : List<Widget>.of(widget.selectedItemBuilder!(context));

    int? hintIndex;
    if (widget.hint != null || (!_enabled && widget.disabledHint != null)) {
      final Widget displayedHint =
          _enabled ? widget.hint! : widget.disabledHint ?? widget.hint!;

      hintIndex = buttonItems.length;
      buttonItems.add(DefaultTextStyle(
        style: _textStyle!.copyWith(color: Theme.of(context).hintColor),
        child: IgnorePointer(
          child: displayedHint,
        ),
      ));
    }

    final EdgeInsetsGeometry padding =
        ButtonTheme.of(context).alignedDropdown &&
                widget._inputDecoration == null
            ? _kAlignedButtonPadding
            : _kUnalignedButtonPadding;

    final buttonHeight =
        _buttonStyle?.height ?? (widget.isDense ? _denseButtonHeight : null);

    final Widget innerItemsWidget = buttonItems.isEmpty
        ? const SizedBox.shrink()
        : ValueListenableBuilder(
            valueListenable: widget.valueListenable ??
                widget.multiValueListenable ??
                ValueNotifier(null),
            builder: (context, _, __) {
              _uniqueValueAssert(
                widget.items,
                widget.valueListenable,
                widget.multiValueListenable,
              );
              Widget item = buttonItems[_selectedIndex ?? hintIndex ?? 0];
              if (item is DropdownItem) {
                item = item.copyWith(alignment: widget.alignment);
              }

              // When both buttonHeight & buttonWidth are specified, we don't have to use IndexedStack,
              // which enhances the performance when dealing with big items list.
              // Note: Both buttonHeight & buttonWidth must be specified to avoid changing
              // button's size when selecting different items, which is a bad UX.
              return buttonHeight != null && _buttonStyle?.width != null
                  ? Align(
                      alignment: widget.alignment,
                      child: item,
                    )
                  : IndexedStack(
                      index: _selectedIndex ?? hintIndex,
                      alignment: widget.alignment,
                      children: buttonHeight != null
                          ? buttonItems
                          : buttonItems.map((item) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[item],
                              );
                            }).toList(),
                    );
            },
          );

    Widget result = DefaultTextStyle(
      style: _enabled
          ? _textStyle!
          : _textStyle!.copyWith(color: Theme.of(context).disabledColor),
      child: widget.customButton ??
          _ConditionalDecoratedBox(
            decoration: _buttonStyle?.decoration?.copyWith(
              boxShadow: _buttonStyle!.decoration!.boxShadow ??
                  kElevationToShadow[_buttonStyle!.elevation ?? 0],
            ),
            foregroundDecoration: _buttonStyle?.foregroundDecoration?.copyWith(
              boxShadow: _buttonStyle!.foregroundDecoration!.boxShadow ??
                  kElevationToShadow[_buttonStyle!.elevation ?? 0],
            ),
            height: buttonHeight,
            width: _buttonStyle?.width,
            child: Padding(
              padding: (_buttonStyle?.padding ?? padding).add(
                // When buttonWidth & dropdownWidth is null, their width will be calculated
                // from the maximum width of menu items or the hint text (width of IndexedStack).
                // We need to add menu's horizontal padding so menu width adapts to max items width with padding properly
                _buttonStyle?.width == null && _dropdownStyle.width == null
                    ? _buttonAdditionalHPadding()
                    : EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.isExpanded)
                    Expanded(child: innerItemsWidget)
                  else
                    innerItemsWidget,
                  IconTheme(
                    data: IconThemeData(
                      color: _iconColor,
                      size: _iconStyle.iconSize,
                    ),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isMenuOpen,
                      builder: (BuildContext context, bool isOpen, _) {
                        return _iconStyle.openMenuIcon != null
                            ? isOpen
                                ? _iconStyle.openMenuIcon!
                                : _iconStyle.icon
                            : _iconStyle.icon;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    if (!DropdownButtonHideUnderline.at(context)) {
      final double bottom = widget.isDense ? 0.0 : 8.0;
      result = Stack(
        children: <Widget>[
          result,
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: bottom,
            child: widget.underline ??
                Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFBDBDBD),
                        width: 0.0,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      );
    }

    final MouseCursor effectiveMouseCursor =
        WidgetStateProperty.resolveAs<MouseCursor>(
      WidgetStateMouseCursor.clickable,
      <WidgetState>{
        if (!_enabled) WidgetState.disabled,
      },
    );

    result = KeyedSubtree(key: _buttonRectKey, child: result);

    // When an InputDecoration is provided, use it instead of using an InkWell
    // that overflows in some cases (such as showing an errorText) and requires
    // additional logic to manage clipping properly.
    // A filled InputDecoration is able to fill the InputDecorator container
    // without overflowing. It also supports blending the hovered color.
    // According to the Material specification, the overlay colors should be
    // visible only for filled dropdown button, see:
    // https://m2.material.io/components/menus#dropdown-menu
    if (widget._inputDecoration != null) {
      InputDecoration effectiveDecoration = widget._inputDecoration!;
      if (_isFocused) {
        final focusColor = effectiveDecoration.focusColor;
        // For compatibility, override the fill color when focusColor is set.
        if (focusColor != null) {
          effectiveDecoration =
              effectiveDecoration.copyWith(fillColor: focusColor);
        }
      }
      result = Focus(
        canRequestFocus: _enabled,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        child: MouseRegion(
          onEnter: (PointerEnterEvent event) {
            if (!_isHovering) {
              setState(() {
                _isHovering = true;
              });
            }
          },
          onExit: (PointerExitEvent event) {
            if (_isHovering) {
              setState(() {
                _isHovering = false;
              });
            }
          },
          cursor: effectiveMouseCursor,
          child: GestureDetector(
            onTap: _enabled && !widget.openWithLongPress ? _handleTap : null,
            onLongPress:
                _enabled && widget.openWithLongPress ? _handleTap : null,
            behavior: HitTestBehavior.opaque,
            child: InputDecorator(
              decoration: effectiveDecoration,
              isEmpty: widget._isEmpty,
              isFocused: _isFocused,
              isHovering: _isHovering,
              child: result,
            ),
          ),
        ),
      );
    } else {
      result = InkWell(
        mouseCursor: effectiveMouseCursor,
        onTap: _enabled && !widget.openWithLongPress ? _handleTap : null,
        onLongPress: _enabled && widget.openWithLongPress ? _handleTap : null,
        canRequestFocus: _enabled,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        overlayColor: _buttonStyle?.overlayColor,
        enableFeedback: false,
        borderRadius: _getButtonBorderRadius(context),
        child: result,
      );
    }

    final bool childHasButtonSemantic = hintIndex != null ||
        (_selectedIndex != null && widget.selectedItemBuilder == null);
    return Semantics(
      button: !childHasButtonSemantic,
      child: Actions(
        actions: _actionMap,
        child: result,
      ),
    );
  }
}

/// A [FormField] that contains a [DropdownButton2].
///
/// This is a convenience widget that wraps a [DropdownButton2] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] allows one to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a [GlobalKey] to the constructor and use [GlobalKey.currentState] to
/// save or reset the form field.
///
/// See also:
///
///  * [DropdownButton2], which is the underlying text field without the [Form]
///    integration.
class DropdownButtonFormField2<T> extends FormField<T> {
  /// Creates a [DropdownButton2] widget that is a [FormField], wrapped in an
  /// [InputDecorator].
  ///
  /// For a description of the `onSaved`, `validator`, or `autovalidateMode`
  /// parameters, see [FormField]. For the rest (other than [decoration]), see
  /// [DropdownButton2].
  DropdownButtonFormField2({
    super.key,
    required List<DropdownItem<T>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    ValueListenable<T?>? valueListenable,
    ValueListenable<List<T>>? multiValueListenable,
    Widget? hint,
    Widget? disabledHint,
    this.onChanged,
    OnMenuStateChangeFn? onMenuStateChange,
    TextStyle? style,
    bool isDense = true,
    bool isExpanded = false,
    FocusNode? focusNode,
    bool autofocus = false,
    InputDecoration? decoration,
    super.onSaved,
    super.validator,
    AutovalidateMode? autovalidateMode,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    FormFieldButtonStyleData? buttonStyleData,
    IconStyleData iconStyleData = const IconStyleData(),
    DropdownStyleData dropdownStyleData = const DropdownStyleData(),
    MenuItemStyleData menuItemStyleData = const MenuItemStyleData(),
    DropdownSearchData<T>? dropdownSearchData,
    DropdownSeparator<T>? dropdownSeparator,
    Widget? customButton,
    bool openWithLongPress = false,
    bool barrierDismissible = true,
    bool barrierCoversButton = true,
    Color? barrierColor,
    String? barrierLabel,
    Listenable? openDropdownListenable,
  })  : assert(
          valueListenable == null || multiValueListenable == null,
          'Only one of valueListenable or multiValueListenable can be used.',
        ),
        decoration = decoration ?? const InputDecoration(),
        super(
          initialValue: valueListenable != null
              ? valueListenable.value
              : multiValueListenable?.value.lastOrNull,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<T> field) {
            final _DropdownButtonFormField2State<T> state =
                field as _DropdownButtonFormField2State<T>;
            final InputDecoration decorationArg =
                decoration ?? const InputDecoration();
            final InputDecoration effectiveDecoration =
                decorationArg.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );

            final bool showSelectedItem = items != null &&
                items
                    .where((DropdownItem<T> item) => item.value == state.value)
                    .isNotEmpty;
            final bool isDropdownEnabled =
                onChanged != null && items != null && items.isNotEmpty;
            // If decoration hintText is provided, use it as the default value for both hint and disabledHint.
            final Widget? decorationHint = effectiveDecoration.hintText != null
                ? Text(
                    effectiveDecoration.hintText!,
                    style: effectiveDecoration.hintStyle,
                    textDirection: effectiveDecoration.hintTextDirection,
                    maxLines: effectiveDecoration.hintMaxLines,
                  )
                : null;
            final Widget? effectiveHint = hint ?? decorationHint;
            final Widget? effectiveDisabledHint = disabledHint ?? effectiveHint;
            final bool isHintOrDisabledHintAvailable = isDropdownEnabled
                ? effectiveHint != null
                : effectiveHint != null || effectiveDisabledHint != null;
            final bool isEmpty =
                !showSelectedItem && !isHintOrDisabledHintAvailable;

            final bool shouldHideError =
                (effectiveDecoration.errorStyle?.height ?? 1) == 0;

            final bool hasError = !shouldHideError &&
                (field.hasError ||
                    effectiveDecoration.errorText != null ||
                    effectiveDecoration.error != null);

            // An unFocusable Focus widget so that this widget can detect if its
            // descendants have focus or not.
            return Focus(
              canRequestFocus: false,
              skipTraversal: true,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<T>._formField(
                  items: items,
                  selectedItemBuilder: selectedItemBuilder,
                  valueListenable: valueListenable,
                  multiValueListenable: multiValueListenable,
                  hint: effectiveHint,
                  disabledHint: effectiveDisabledHint,
                  onChanged: onChanged == null ? null : state.didChange,
                  onMenuStateChange: onMenuStateChange,
                  style: style,
                  isDense: isDense,
                  isExpanded: isExpanded,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  enableFeedback: enableFeedback,
                  alignment: alignment,
                  buttonStyleData: buttonStyleData?._toButtonStyleData,
                  iconStyleData: iconStyleData,
                  dropdownStyleData: dropdownStyleData,
                  menuItemStyleData: menuItemStyleData,
                  dropdownSearchData: dropdownSearchData,
                  dropdownSeparator: dropdownSeparator,
                  customButton: customButton,
                  openWithLongPress: openWithLongPress,
                  barrierDismissible: barrierDismissible,
                  barrierCoversButton: barrierCoversButton,
                  barrierColor: barrierColor,
                  barrierLabel: barrierLabel,
                  openDropdownListenable: openDropdownListenable,
                  inputDecoration: effectiveDecoration.copyWith(
                    errorText: field.errorText,
                    // Clear the decoration hintText because DropdownButton has its own hint logic.
                    hintText: effectiveDecoration.hintText != null ? '' : null,
                  ),
                  isEmpty: isEmpty,
                  hasError: hasError,
                ),
              ),
            );
          },
        );

  /// {@macro flutter.material.dropdownButton.onChanged}
  final ValueChanged<T?>? onChanged;

  /// The decoration to show around the dropdown button form field.
  ///
  /// By default, draws a horizontal line under the dropdown button field but
  /// can be configured to show an icon, label, hint text, and error text.
  final InputDecoration decoration;

  @override
  FormFieldState<T> createState() => _DropdownButtonFormField2State<T>();
}

class _DropdownButtonFormField2State<T> extends FormFieldState<T> {
  DropdownButtonFormField2<T> get _dropdownButtonFormField =>
      widget as DropdownButtonFormField2<T>;

  @override
  void didChange(T? value) {
    super.didChange(value);
    _dropdownButtonFormField.onChanged?.call(value);
  }

  @override
  void didUpdateWidget(DropdownButtonFormField2<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _dropdownButtonFormField.onChanged?.call(value);
  }
}
