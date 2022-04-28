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
    LogicalKeyboardKey.pageUp: const Tuple2(0, -1),
    LogicalKeyboardKey.pageDown: const Tuple2(0, 1),
  };

  final bool isSingleSelection;
  int numCols = 1;
  int numRows = 1;
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
    var movement = _arrows[e.logicalKey];
    if (movement == null) {
      if (e.logicalKey == LogicalKeyboardKey.pageUp) {
        movement = Tuple2(0, -numRows);
      } else if (e.logicalKey == LogicalKeyboardKey.pageDown) {
        movement = Tuple2(0, numRows);
      } else if (e.logicalKey == LogicalKeyboardKey.home) {
        movement = Tuple2(0, -_itemsCount);
      } else if (e.logicalKey == LogicalKeyboardKey.end) {
        movement = Tuple2(0, _itemsCount);
      }
    }
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

  void handleArrowMovement(Tuple2<int, int> movement,
      {required bool isControlPressed, required bool isShiftPressed}) {
    int index = _selectionTail + movement.item2 * numCols;
    // Never move out of bound & keep column.
    if (index < 0) {
      index += (numCols - index - 1) ~/ numCols * numCols;
    } else if (index >= _itemsCount) {
      index -= (index - _itemsCount + numCols - 1) ~/ numCols * numCols;
      // Handle the last row.
      if (index >= _itemsCount) {
        index -= numCols;
      }
    }
    index = min(_itemsCount, max(0, index + movement.item1));
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
