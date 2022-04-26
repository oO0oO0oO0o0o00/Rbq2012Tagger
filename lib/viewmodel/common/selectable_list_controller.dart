import 'dart:collection';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

/// Controller of a multiple-selectable list.
class SelectableListController with ChangeNotifier {
  static final _arrows = {
    LogicalKeyboardKey.arrowLeft: const Tuple2(-1, 0),
    LogicalKeyboardKey.arrowRight: const Tuple2(1, 0),
    LogicalKeyboardKey.arrowUp: const Tuple2(0, -1),
    LogicalKeyboardKey.arrowDown: const Tuple2(0, 1),
  };

  final bool isSingleSelection;
  int numCols = 1;
  int _itemsCount = 0;
  int _selectionHead = 0;
  int _selectionTail = 0;
  final _selections = <int>[];
  List<int>? _immutableSelections;
  final Function() onSelectionChanged;

  SelectableListController(
      {this.isSingleSelection = false, required this.onSelectionChanged});

  int get singleSelection => _selectionTail;
  List<int> get selections =>
      _immutableSelections ??= UnmodifiableListView(_selections);
  set itemsCount(int value) => _itemsCount = value;

  void handleItemClick(int index,
      {required bool isControlPressed, required bool isShiftPressed}) {
    _handleCtrl(index, isControlPressed: isControlPressed);
    _handleShiftAndClick(index, isShiftPressed: isShiftPressed);
    onSelectionChanged();
  }

  void _handleShiftAndClick(int index, {required bool isShiftPressed}) {
    if (isShiftPressed) {
      for (var i = min(index, _selectionHead);
          i <= max(index, _selectionHead);
          i++) {
        _selections.add(i);
      }
    } else {
      if (_selections.contains(index)) {
        _selections.remove(index);
      } else {
        _selections.add(index);
      }
      _selectionHead = index;
    }
    _selectionTail = index;
  }

  void _handleCtrl(int index, {required bool isControlPressed}) {
    if (!isControlPressed) {
      _selections.clear();
    } else {
      _selectionTail = index;
    }
  }

  KeyEventResult handleKey(RawKeyEvent e) {
    final movement = _arrows[e.logicalKey];
    if (movement != null) {
      if (e is RawKeyDownEvent) {
        handleArrowMovement(movement,
            isControlPressed: e.isControlPressed,
            isShiftPressed: e.isShiftPressed);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void handleArrowMovement(Tuple2 movement,
          {required bool isControlPressed, required bool isShiftPressed}) =>
      handleMovement(movement.item1 + movement.item2 * numCols,
          isControlPressed: isControlPressed, isShiftPressed: isShiftPressed);

  void handleMovement(int many,
      {required bool isControlPressed, required bool isShiftPressed}) {
    final index = _selectionTail + many;
    if (index < 0 || index >= _itemsCount) {
      return;
    }
    _handleCtrl(index, isControlPressed: isControlPressed);
    if (!isControlPressed || isShiftPressed) {
      _handleShiftAndClick(index, isShiftPressed: isShiftPressed);
    }
    onSelectionChanged();
  }

  void clearSelection() {
    _selectionHead = _selectionTail = 0;
    _selections.clear();
    onSelectionChanged();
  }

  void updateSelection(int index, Selectable item) {
    item.selected = _selections.contains(index);
    item.singleSelected = _selectionTail == index;
  }
}

mixin Selectable {
  bool _singleSelected = false;
  bool _selected = false;

  bool get singleSelected => _singleSelected;

  bool get selected => _selected;

  set singleSelected(bool value) => _singleSelected = value;

  set selected(bool value) => _selected = value;
}
