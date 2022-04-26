import 'dart:async';
import 'package:flutter/widgets.dart';

import '../../service/album_service.dart';
import 'album_core_struct.dart';
import 'album_item_viewmodel.dart';
import 'album_items_sort_mode_viewmodel.dart';
import 'album_controller.dart';
import 'tag_templates_viewmodel.dart';

/// View model for [AlbumPage].
///
/// Different from [AlbumController], this view model
/// handles more basic operations.
class AlbumViewModel with ChangeNotifier {
  AlbumItemsSortModeViewModel _sortMode =
      AlbumItemsSortModeViewModel.defaultMode;

  late final AlbumCoreStruct _albumCoreStruct;

  /// The controller that handles selection-based
  /// and highly UI-related functionalities.
  late final AlbumController controller;

  AlbumViewModel(String path) : _albumCoreStruct = AlbumCoreStruct(path) {
    controller = AlbumController(_albumCoreStruct)
      ..addListener(notifyListeners);
  }

  /// The mode with which items are sorted.
  AlbumItemsSortModeViewModel get sortMode => _sortMode;

  set sortMode(AlbumItemsSortModeViewModel mode) {
    if (mode == _sortMode) return;
    _sortMode = mode;
    _sort();
    notifyListeners();
  }

  TagTemplatesViewModel get tagTemplates => _albumCoreStruct.tagTemplates;
  String get path => _albumCoreStruct.model.path;
  String get pathForDisplay => _albumCoreStruct.model.path;
  bool get dbReady => _albumCoreStruct.model.dbReady;

  Future<bool> isManaged() async =>
      AlbumService.isManaged(_albumCoreStruct.model);

  Future<void> initDatabase() async {
    await AlbumService.initDatabase(_albumCoreStruct.model);
    final cache = _albumCoreStruct.cache;
    if (cache != null) {
      for (var element in cache) {
        element?.updateTags(
            _albumCoreStruct.model, _albumCoreStruct.tagTemplates);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    AlbumService.closeDatabase(_albumCoreStruct.model);
    super.dispose();
  }

  Future<void> closeDatabase() async {
    await AlbumService.closeDatabase(_albumCoreStruct.model);
    notifyListeners();
  }

  Future<void> loadContents() async {
    if (_albumCoreStruct.model.contents != null) return;
    await AlbumService.loadContents(_albumCoreStruct.model);
    _sort();
    notifyListeners();
  }

  AlbumItemViewModel getItem(int index) {
    final cache = _albumCoreStruct.cache!;
    var item = cache[index];
    if (item != null) return item;
    item = AlbumItemViewModel(_albumCoreStruct.model.contents![index]);
    if (_albumCoreStruct.model.dbReady) {
      item.updateTags(_albumCoreStruct.model, _albumCoreStruct.tagTemplates);
    }
    cache[index] = item;
    controller.updateSelection(index, item);
    return item;
  }

  int getItemsCount() => _albumCoreStruct.model.contents?.length ?? 0;

  void _sort() {
    final cache = _albumCoreStruct.cache =
        List.filled(_albumCoreStruct.model.contents!.length, null);
    controller.reset(cache.length);
    sortMode.sort(_albumCoreStruct.model.contents!, sortMode.reversed);
  }
}
