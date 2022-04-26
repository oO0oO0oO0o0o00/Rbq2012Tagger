import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/services.dart';
import '../../util/keyboard.dart';

import '../../model/model.dart';
import '../../service/album_service.dart';
import '../common/selectable_list_controller.dart';
import 'album_core_struct.dart';
import 'album_item_viewmodel.dart';
import 'tag_of_selections.dart';
import 'tagged_viewmodel.dart';

/// Controller of [AlbumPage].
///
/// Different from [AlbumViewModel], this controller
/// handles more highly UI-related operations and/or
/// selection-based functionalities.
class AlbumController with ChangeNotifier {
  final AlbumCoreStruct _albumCoreStruct;

  late final SelectableListController _selectionController =
      SelectableListController(onSelectionChanged: () {
    updateSelections(_albumCoreStruct.cache!);
  });

  final _tagsOfSelections = TagsOfSelections();

  final scrollController = ScrollController();

  final double preferredAspectRatio = .75;

  double? _oldItemHeight;

  double _itemHeight = 240.0;

  AlbumController(AlbumCoreStruct albumCoreStruct)
      : _albumCoreStruct = albumCoreStruct;

  get selections => _selectionController.selections;

  int get numCols => _selectionController.numCols;

  double get itemHeight => _itemHeight;

  void reset(int itemsCount) {
    _selectionController.clearSelection();
    _selectionController.itemsCount = itemsCount;
  }

  /// Calculate number of columns from fixed
  /// height and max aspect ratio
  void handleResize(double width) {
    if (!scrollController.hasClients) return;
    final position = scrollController.position.pixels;
    bool changed = false;
    if (_oldItemHeight != _itemHeight) {
      changed = true;
    }
    final newNumCols =
        max(1, (width / itemHeight * preferredAspectRatio).floor());
    if (numCols != newNumCols) {
      changed = true;
    }
    if (changed) {
      final oldItemHeight = _oldItemHeight ?? _itemHeight;
      scrollController
          .jumpTo(position / oldItemHeight * numCols / newNumCols * itemHeight);
      _selectionController.numCols = newNumCols;
      _oldItemHeight = _itemHeight;
    }
  }

  void scroll(double amount) {
    scrollController.jumpTo(min(
        max(scrollController.position.minScrollExtent,
            scrollController.position.pixels + amount * 8),
        scrollController.position.maxScrollExtent));
  }

  void zoom(double amount) {
    _oldItemHeight = _itemHeight;
    _itemHeight = min(max(180, _itemHeight + amount * 3), 640);
    notifyListeners();
  }

  void handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      if (isControlPressed()) {
        zoom(-event.scrollDelta.dy);
      } else {
        scroll(event.scrollDelta.dy);
      }
    }
  }

  void updateSelections(List<AlbumItemViewModel?> cache) {
    cache.forEachIndexed((index, item) {
      if (item != null) {
        updateSelection(index, item);
      }
    });
    _tagsOfSelections.invalidate();
    notifyListeners();
  }

  void updateSelection(int index, AlbumItemViewModel item) =>
      _selectionController.updateSelection(index, item);

  Future<void> addTagToSelected(String tag) async =>
      toggleTagForSelected(tag, AlbumService.addTag);

  Future<void> removeTagFromSelected(String tag) async =>
      toggleTagForSelected(tag, AlbumService.removeTag);

  Future<void> toggleTagForSelected(String tag,
      FutureOr<bool> Function(Album album, Tagged tagged) operation) async {
    if (!_albumCoreStruct.model.dbReady) return;
    Iterable<int> selections;
    if (_selectionController.selections.isEmpty) return;
    selections = List.unmodifiable(_selectionController.selections);
    for (final selection in selections) {
      await operation(
          _albumCoreStruct.model,
          Tagged(
              name: _albumCoreStruct.model.contents![selection].name,
              tag: tag));
      _albumCoreStruct.cache![selection]
          ?.updateTags(_albumCoreStruct.model, _albumCoreStruct.tagTemplates);
    }
    _tagsOfSelections.invalidate();
    notifyListeners();
  }

  Future<void> removeTagFromItem(AlbumItemViewModel item, String tag) async {
    if (!_albumCoreStruct.model.dbReady) return;
    await AlbumService.removeTag(
        _albumCoreStruct.model, Tagged(name: item.name, tag: tag));
    item.updateTags(_albumCoreStruct.model, _albumCoreStruct.tagTemplates);
    _tagsOfSelections.invalidate();
    notifyListeners();
  }

  int getTagsOfSelectedItemsCount(bool intersectionMode) {
    if (!_albumCoreStruct.model.dbReady) return 0;
    final list = intersectionMode
        ? _tagsOfSelections.intersection
        : _tagsOfSelections.union;
    if (list != null && !_tagsOfSelections.invalid) {
      return list.length;
    }
    (() async {
      await _tagsOfSelections.loadTags(
          _albumCoreStruct.model,
          _albumCoreStruct.tagTemplates,
          _selectionController.selections
              .map((e) => _albumCoreStruct.model.contents![e].name)
              .toList(),
          intersectionMode: intersectionMode);
      notifyListeners();
    })();
    return list?.length ?? 0;
  }

  TaggedViewModel getTagOfSelectedItemsAt(int index, bool intersectionMode) =>
      (intersectionMode
          ? _tagsOfSelections.intersection
          : _tagsOfSelections.union)![index];

  void handleItemClick(int index,
          {required bool isControlPressed, required bool isShiftPressed}) =>
      _selectionController.handleItemClick(index,
          isControlPressed: isControlPressed, isShiftPressed: isShiftPressed);

  KeyEventResult handleKey(FocusNode n, RawKeyEvent e) {
    final selectionHandled = _selectionController.handleKey(e);

    if (selectionHandled != KeyEventResult.ignored) {
      // Adjust scroll position for moving selection with arrows.
      handleMoveSelection(itemHeight, scrollController);
      return selectionHandled;
    }

    if (e is! RawKeyDownEvent) return KeyEventResult.ignored;

    final shortcut = getSingleKeyShortcut(e.logicalKey.keyLabel);
    if (shortcut == null) return KeyEventResult.ignored;
    final tag = _albumCoreStruct.tagTemplates.getByShortcut(shortcut);
    if (tag == null) return KeyEventResult.ignored;
    if (e.isAltPressed) {
      removeTagFromSelected(tag.name);
    } else {
      addTagToSelected(tag.name);
    }
    if (e.isShiftPressed) {
      handleMovement(1, isControlPressed: false, isShiftPressed: false);
      handleMoveSelection(itemHeight, scrollController);
    }
    return KeyEventResult.skipRemainingHandlers;
  }

  void handleArrowMovement(Tuple2 movement,
          {required bool isControlPressed, required bool isShiftPressed}) =>
      _selectionController.handleArrowMovement(movement,
          isControlPressed: isControlPressed, isShiftPressed: isShiftPressed);

  void handleMovement(int many,
          {required bool isControlPressed, required bool isShiftPressed}) =>
      _selectionController.handleMovement(many,
          isControlPressed: isControlPressed, isShiftPressed: isShiftPressed);

  void handleMoveSelection(
      double itemHeight, ScrollController scrollController) {
    final int animateTarget = _selectionController.singleSelection;
    final double animateOffset =
        (animateTarget ~/ _selectionController.numCols).toDouble() * itemHeight;
    final double? animateTo;
    final scrollPosition = scrollController.position.pixels;
    final viewportHeight = scrollController.position.viewportDimension;
    if (animateOffset < scrollPosition) {
      animateTo = animateOffset - itemHeight / 2;
    } else if (animateOffset + itemHeight >
        scrollController.position.pixels + viewportHeight) {
      animateTo = animateOffset - viewportHeight + itemHeight * 3 / 2;
    } else {
      animateTo = null;
    }
    if (animateTo != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await scrollController.animateTo(animateTo!,
            duration: const Duration(milliseconds: 100), curve: Curves.ease);
      });
    }
  }
}
