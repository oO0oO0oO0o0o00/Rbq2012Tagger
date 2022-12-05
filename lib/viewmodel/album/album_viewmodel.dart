import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

import '../../model/file_conflict_resolve_config.dart';
import '../../model/global/batch_action.dart';
import '../../model/global/search_options.dart';
import '../../model/model.dart';
import '../../service/album_service.dart';
import '../../util/search.dart';
import '../tag_templates_viewmodel.dart';
import 'album_controller.dart';
import 'album_core_struct.dart';
import 'album_item_viewmodel.dart';
import 'album_items_sort_mode_viewmodel.dart';

/// View model for [AlbumPage].
///
/// Different from [AlbumController], this view model
/// handles more basic operations.
class AlbumViewModel with ChangeNotifier {
  AlbumItemsSortModeViewModel _sortMode = AlbumItemsSortModeViewModel.defaultMode;

  SearchOptions? _filter;

  var _loading = false;

  late final AlbumCoreStruct _albumCoreStruct;

  /// The controller that handles selection-based
  /// and highly UI-related functionalities.
  late final AlbumController controller;

  bool get loading => _loading;

  set loading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  AlbumViewModel(String path, {required TagTemplatesViewModel tagTemplates})
      : _albumCoreStruct = AlbumCoreStruct(path, tagTemplates: tagTemplates) {
    controller = AlbumController(_albumCoreStruct)..addListener(notifyListeners);
  }

  /// The mode with which items are sorted.
  AlbumItemsSortModeViewModel get sortMode => _sortMode;

  set sortMode(AlbumItemsSortModeViewModel mode) {
    if (mode == _sortMode) return;
    _sortMode = mode;
    _sort();
    notifyListeners();
  }

  SearchOptions? get filter => _filter;

  set filter(SearchOptions? value) {
    _filter = value;
    _sort();
    notifyListeners();
  }

  TagTemplatesViewModel get tagTemplates => _albumCoreStruct.tagTemplates;
  String get path => _albumCoreStruct.model.path;
  String get pathForDisplay => _albumCoreStruct.model.path;
  bool get dbReady => _albumCoreStruct.model.dbReady;

  Future<bool> isManaged() async => AlbumService.isManaged(_albumCoreStruct.model);

  Future<void> openDatabase() async => await AlbumService.getDatabase(_albumCoreStruct.model);

  @override
  void dispose() {
    AlbumService.closeDatabase(_albumCoreStruct.model);
    super.dispose();
  }

  Future<void> closeDatabase() async {
    await AlbumService.closeDatabase(_albumCoreStruct.model);
    notifyListeners();
  }

  // Future<void> load() async {
  //   if (_albumCoreStruct.model.contents != null) return;
  //   await AlbumService.loadContents(_albumCoreStruct.model);
  //   _sort();
  //   notifyListeners();
  // }

  Future<void> loadContents() async {
    if (_albumCoreStruct.model.contents != null) return;
    await AlbumService.loadContents(_albumCoreStruct.model);
    _sort();
    notifyListeners();
  }

  AlbumItemViewModel getItem(int index) {
    final cache = _albumCoreStruct.cache!;
    var item = cache[index];
    if (item == null) {
      item = AlbumItemViewModel(_albumCoreStruct.filteredContents![index]);
      if (_albumCoreStruct.model.dbReady) {
        item.updateTags(_albumCoreStruct.model, tagTemplates);
      }
      cache[index] = item;
    }
    controller.updateSelection(index, item);
    return item;
  }

  int getItemsCount() => _albumCoreStruct.filteredContents?.length ?? 0;

  void _sort() async {
    _albumCoreStruct.filteredContents = await _getFiltered(_filter);
    final cache = _albumCoreStruct.cache = List.filled(_albumCoreStruct.filteredContents!.length, null);
    controller.reset(cache.length);
    sortMode.sort(_albumCoreStruct.filteredContents!, sortMode.reversed);
  }

  Future<List<AlbumItem>?> _getFiltered(SearchOptions? filter) async {
    if (filter == null) return null;
    final filtered = List<AlbumItem>.empty(growable: true);
    for (final item in _albumCoreStruct.model.contents!) {
      final byName = filter.byName,
          fromSizeKb = filter.fromSizeKb,
          toSizeKb = filter.toSizeKb,
          fromTime = filter.fromTime,
          toTime = filter.toTime;
      if (byName != null && !wildcardMatches(byName, item.name)) {
        continue;
      }
      if (fromSizeKb != null && item.fileSizeBytes ~/ 1024 < fromSizeKb ||
          toSizeKb != null && item.fileSizeBytes ~/ 1024 > toSizeKb) {
        continue;
      }
      if (fromTime != null && item.dateTime.isBefore(fromTime) || toTime != null && item.dateTime.isAfter(toTime)) {
        continue;
      }
      if (filter.tags.isNotEmpty || filter.xtags.isNotEmpty) {
        final tags = await AlbumService.loadTags(_albumCoreStruct.model, item.name);
        if (filter.tags.isNotEmpty && !tags.any(filter.tags.contains) ||
            filter.xtags.isNotEmpty && tags.any(filter.xtags.contains)) {
          continue;
        }
      }
      filtered.add(item);
    }
    return filtered;
  }

  Future<void> performBatchAction(BatchAction action,
      {required AlbumViewModel Function(String path, String referredBy) getAlbumViewModel,
      required void Function(String path, String referredBy) releaseAlbumViewModel,
      required Future<Map<String, FileConflictAction>?> Function(List<Tuple2<File, File>> conflicts)
          conflictResolver}) async {
    loading = true;
    final destFolder = action.path!;
    final selections = controller.selections.map((e) => getItem(e)).toList();
    if (action.enableMoveCopyAction) {
      final targetViewModel = getAlbumViewModel(destFolder, path);
      if (targetViewModel.loading) {
        throw "why is it loading";
      }
      if (!targetViewModel.dbReady) {
        await targetViewModel.openDatabase();
      }
      // Preflight and handle file conflicts.
      List<Tuple2<AlbumItemViewModel, AlbumItemViewModel>> jobs = [];
      List<Tuple2<File, File>> conflicts = [];
      for (var item in selections) {
        final preflightResult =
            await AlbumService.preflightImportFromAlbumItem(targetViewModel._albumCoreStruct.model, item.model);
        if (preflightResult.item2 != null) {
          conflicts.add(preflightResult.item2!);
        }
        jobs.add(Tuple2(item, AlbumItemViewModel(preflightResult.item1)));
      }
      final Map<String, FileConflictAction>? conflictActions;
      if (conflicts.isNotEmpty) {
        conflictActions = await conflictResolver(conflicts);
      } else {
        conflictActions = {};
      }
      if (conflictActions == null) {
        loading = false;
        return;
      }
      // Process for each item.
      for (var job in jobs) {
        final srcItem = job.item1;
        var dstItem = job.item2;
        // Apply conflict handling.
        final conflictAction = conflictActions[dstItem.path];
        switch (conflictAction) {
          case FileConflictAction.skip:
            continue;
          case FileConflictAction.overwrite:
          case null:
            break;
          case FileConflictAction.rename:
            dstItem = AlbumItemViewModel(await AlbumService.useNextAvailableName(dstItem.model));
            break;
        }
        // Migration of tags.
        var itemTags = srcItem.getTags().map((e) => e.tag).toSet();
        if (action.enableTaggingAction) {
          for (var newTag in action.tags) {
            itemTags.add(newTag);
          }
          for (var oldTag in action.xtags) {
            itemTags.remove(oldTag);
          }
        }
        for (var tag in itemTags) {
          targetViewModel.controller.addTagToItem(dstItem, tag, preventUpdate: true);
        }
        // Copy or move.
        await AlbumService.importPictureFromAlbumItem(dest: dstItem.model, src: srcItem.model, copy: action.copy);
        // Remove local tags for moved file.
        if (!action.copy) {
          AlbumService.removeItemtags(_albumCoreStruct.model, srcItem.model);
        }
        targetViewModel.notifyListeners();
        releaseAlbumViewModel(targetViewModel.path, path);
      }
    } else if (action.enableTaggingAction) {
      for (var item in selections) {
        final itemTags = item.getTags();
        for (var newTag in action.tags) {
          if (itemTags.any((element) => element.tag == newTag)) continue;
          await controller.addTagToItem(item, newTag, preventUpdate: true);
        }
        for (var oldTag in action.xtags) {
          if (!itemTags.any((element) => element.tag == oldTag)) continue;
          await controller.removeTagFromItem(item, oldTag, preventUpdate: true);
        }
      }
    }
    controller.invalidateSelections();
    notifyListeners();
    loading = false;
  }
}
