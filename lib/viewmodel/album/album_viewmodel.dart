import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import '../../model/model.dart';
import '../../service/album_service.dart';
import '../common/selectable_list_controller.dart';
import 'album_item_viewmodel.dart';
import 'album_items_sort_mode_viewmodel.dart';
import 'tag_templates_viewmodel.dart';
import 'tagged_viewmodel.dart';

class AlbumViewModel with ChangeNotifier {
  final Album _model;

  AlbumItemsSortModeViewModel _sortMode =
      AlbumItemsSortModeViewModel.defaultMode;

  List<AlbumItemViewModel?>? _cache;

  late final SelectableListController selectionController =
      SelectableListController(changedNotifier: () {
    _updateSelections();
    notifyListeners();
  });

  bool movingSelection = false;

  int visibleIndex = 0;

  final tagTemplatesViewModel = TagTemplatesViewModel();

  final tagsOfSelections = TagsOfSelections();

  AlbumItemsSortModeViewModel get sortMode => _sortMode;

  set sortMode(AlbumItemsSortModeViewModel mode) {
    if (mode == _sortMode) return;
    _sortMode = mode;
    _sort();
    notifyListeners();
  }

  void _sort() {
    final cache = _cache = List.filled(_model.contents!.length, null);
    selectionController.itemsCount = cache.length;
    selectionController.clearSelection();
    sortMode.sort(_model.contents!, sortMode.reversed);
  }

  AlbumViewModel(String path) : _model = AlbumService.getAlbum(path);

  String get path => _model.path;
  String get pathForDisplay => _model.path;
  bool get dbReady => _model.dbReady;

  Future<bool> isManaged() async => AlbumService.isManaged(_model);

  Future<void> initDatabase() async {
    await AlbumService.initDatabase(_model);
    final cache = _cache;
    if (cache != null) {
      for (var element in cache) {
        element?.updateTags(_model, tagTemplatesViewModel);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    AlbumService.closeDatabase(_model);
    super.dispose();
  }

  Future<void> closeDatabase() async {
    await AlbumService.closeDatabase(_model);
    notifyListeners();
  }

  Future<void> loadContents() async {
    if (_model.contents != null) return;
    await AlbumService.loadContents(_model);
    _sort();
    notifyListeners();
  }

  AlbumItemViewModel getItem(int index) {
    final cache = _cache!;
    var item = cache[index];
    if (item != null) return item;
    item = AlbumItemViewModel(_model.contents![index]);
    if (_model.dbReady) {
      item.updateTags(_model, tagTemplatesViewModel);
    }
    cache[index] = item;
    selectionController.updateSelection(index, item);
    return item;
  }

  int getItemsCount() => _model.contents?.length ?? 0;

  void _updateSelections() {
    _cache!.forEachIndexed((index, item) {
      if (item != null) {
        selectionController.updateSelection(index, item);
      }
    });
    tagsOfSelections.invalidate();
  }

  Future<void> addTagToSelected(String tag) async =>
      toggleTagForSelected(tag, AlbumService.addTag);

  Future<void> removeTagFromSelected(String tag) async =>
      toggleTagForSelected(tag, AlbumService.removeTag);

  Future<void> toggleTagForSelected(String tag,
      FutureOr<bool> Function(Album album, Tagged tagged) operation) async {
    if (!_model.dbReady) return;
    Iterable<int> selections;
    if (selectionController.selections.isEmpty) return;
    selections = List.unmodifiable(selectionController.selections);
    final cache = _cache!;
    for (final selection in selections) {
      await operation(
          _model, Tagged(name: _model.contents![selection].name, tag: tag));
      cache[selection]?.updateTags(_model, tagTemplatesViewModel);
    }
    tagsOfSelections.invalidate();
    notifyListeners();
  }

  Future<void> removeTag(AlbumItemViewModel item, String tag) async {
    if (!_model.dbReady) return;
    await AlbumService.removeTag(_model, Tagged(name: item.name, tag: tag));
    item.updateTags(_model, tagTemplatesViewModel);
    tagsOfSelections.invalidate();
    notifyListeners();
  }

  int getTagsOfSelectedItemsCount(bool intersectionMode) {
    if (!_model.dbReady) return 0;
    final list = intersectionMode
        ? tagsOfSelections.intersection
        : tagsOfSelections.union;
    if (list != null && !tagsOfSelections.invalid) {
      return list.length;
    }
    (() async {
      await tagsOfSelections.loadTags(
          _model,
          tagTemplatesViewModel,
          selectionController.selections
              .map((e) => _model.contents![e].name)
              .toList(),
          intersectionMode: intersectionMode);
      notifyListeners();
    })();
    return list?.length ?? 0;
  }

  TaggedViewModel getTagOfSelectedItemsAt(int index, bool intersectionMode) =>
      (intersectionMode
          ? tagsOfSelections.intersection
          : tagsOfSelections.union)![index];
}

class TagsOfSelections {
  List<TaggedViewModel>? _intersection;
  List<TaggedViewModel>? _union;

  bool _invalid = false;

  List<TaggedViewModel>? get intersection => _intersection;
  List<TaggedViewModel>? get union => _union;
  bool get invalid => _invalid;

  void invalidate() => _invalid = true;

  Future<void> loadTags(Album album,
      TagTemplatesViewModel tagTemplatesViewModel, List<String> selection,
      {required bool intersectionMode}) async {
    final list = (await AlbumService.loadTagsForPictures(album, selection,
            intersectionMode: intersectionMode))
        .map((e) => TaggedViewModel(e, tagTemplatesViewModel.getByName(e)))
        .toList();
    if (intersectionMode) {
      _intersection = list;
    } else {
      _union = list;
    }
    _invalid = false;
  }
}
