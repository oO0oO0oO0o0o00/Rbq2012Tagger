import 'package:flutter/widgets.dart';
import 'package:synchronized/synchronized.dart';

import '../model/global/color_spec.dart';
import '../model/global/model.dart';
import '../service/tag_templates_service.dart';

/// View model for tags management page.
class TagTemplatesViewModel with ChangeNotifier {
  List<TagTemplate>? _cache;

  EditingItemViewModel? _editingItem;

  /// The item that is currently being edited or created.
  EditingItemViewModel? get editingItem => _editingItem;

  final _cacheLock = Lock();

  TagTemplatesViewModel();

  TagTemplate getItem(int index) => _cache![index];

  int getItemsCount() {
    final cache = _cache;
    if (cache != null) return cache.length;
    _loadCache();
    return 0;
  }

  Future<List<TagTemplate>> _loadCache({bool reload = false}) async {
    final cache = _cache;
    if (!reload && cache != null) return cache;
    final ret = _cache = await TagTemplatesService.getAll();
    notifyListeners();
    return ret;
  }

  /// Moves (Reorders) a tag template.
  Future<void> move(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    late TagTemplate item;
    String? insertAfter;
    // The cache must be present.
    final cache = await _loadCache();
    // There're some special considerations when moving the item being created.
    var movingCreatingItem = false;
    _cacheLock.synchronized(() {
      // Find the item that will be right before the insertion point.
      insertAfter = newIndex > 0 ? cache[newIndex - 1].name : null;
      // The item being created is not actually persisted so skip ahead of it.
      if (insertAfter != null &&
          (_editingItem?.isInsertionMode ?? false) &&
          insertAfter == _editingItem?.previous.name) {
        insertAfter = newIndex > 1 ? cache[newIndex - 2].name : null;
      }
      item = cache.removeAt(oldIndex);
      final editingItem = _editingItem;
      // Insertion index may change because of the removal.
      final newNewIndex = newIndex - (oldIndex < newIndex ? 1 : 0);
      // Special considerations when there's an item being created.
      if (editingItem != null && editingItem.isInsertionMode) {
        // If moving it, move its insertion index,
        // and remember that nothing need to be done at the backend.
        if (oldIndex == editingItem.insertAt) {
          movingCreatingItem = true;
          editingItem.insertAt = newNewIndex;
          // Otherwise just move the creating item's insertion index
          // if we're moving something across it.
        } else if (oldIndex < editingItem.insertAt &&
            editingItem.insertAt < newIndex) {
          editingItem.insertAt--;
        } else if (oldIndex > editingItem.insertAt &&
            editingItem.insertAt >= newIndex) {
          editingItem.insertAt++;
        }
      }
      // Perform the insertion in the cache.
      cache.insert(newNewIndex, item);
    });
    // If the item being moved is the item being created,
    // this is all we need to do.
    if (movingCreatingItem) return;
    // Otherwise perform the actual insertion in the backend.
    await TagTemplatesService.move(item, insertAfter);
    // Reload into the cache and
    // insert the item being created back into the cache.
    await _loadCache(reload: true);
    _insertCreatingItemToCache();
  }

  void beginEditing(TagTemplate item) {
    discardEditing();
    _editingItem = EditingItemViewModel.edit(item);
    notifyListeners();
  }

  /// Commit an ongoing creation/editing to the backend.
  Future<bool> commitEditing() async {
    final item = _editingItem;
    if (item == null) return false;
    if (!item.precheck(_cache)) {
      notifyListeners();
      return false;
    }
    bool result;
    if (item.isInsertionMode) {
      result = await TagTemplatesService.insert(item.current,
          item.insertAt == 0 ? null : _cache![item.insertAt - 1].name);
    } else {
      result = await TagTemplatesService.update(item.previous, item.current);
    }
    if (!result) {
      item.errorText = "failed";
      return false;
    }
    _editingItem = null;
    await _loadCache(reload: true);
    return true;
  }

  void discardEditing() {
    final item = _editingItem;
    if (item != null && item.isInsertionMode) {
      _cache?.removeAt(item.insertAt);
    }
    _editingItem = null;
    notifyListeners();
  }

  Future<void> deleteItem(TagTemplate item) async {
    _cacheLock.synchronized(() {
      final index = _cache!.indexWhere((element) => item.name == element.name);
      _cache!.removeAt(index);
      // Removal of an item ahead of the item being created
      // would change its insertion index.
      final editingItem = _editingItem;
      if (editingItem != null) {
        if (index < editingItem.insertAt) {
          editingItem.insertAt--;
        }
      }
    });
    if (!await TagTemplatesService.remove(item)) return;
    await _loadCache(reload: true);
    _insertCreatingItemToCache();
  }

  void _insertCreatingItemToCache() {
    final item = _editingItem;
    final cache = _cache;
    if (item == null || cache == null || !item.isInsertionMode) return;
    _cacheLock.synchronized(() {
      cache.insert(item.insertAt, item.previous);
    });
  }

  void beginCreateItemAfter(TagTemplate after) {
    discardEditing();
    _beginCreateItemAt(_cache!.indexOf(after) + 1);
  }

  void beginCreateItemAtTheEnd() {
    discardEditing();
    _beginCreateItemAt(_cache!.length);
  }

  void _beginCreateItemAt(int at) {
    final item = TagTemplate(name: "", color: ColorSpec.pink);
    _editingItem = EditingItemViewModel.insert(item, at);
    _insertCreatingItemToCache();
    notifyListeners();
  }
}

class EditingItemViewModel {
  final TagTemplate previous;
  final TagTemplate current;
  // String name;
  String? errorText;
  int insertAt;
  bool get isInsertionMode => insertAt >= 0;

  EditingItemViewModel.edit(this.previous)
      : current = TagTemplate.from(previous),
        insertAt = -1;

  EditingItemViewModel.insert(this.previous, this.insertAt)
      : current = TagTemplate(name: "", color: ColorSpec.pink);

  bool precheck(List<TagTemplate>? cachedExistingItems) {
    if (current.name.isEmpty) {
      errorText = "Tag cannot be empty";
      return false;
    }
    if (cachedExistingItems != null) {
      for (final item in cachedExistingItems) {
        if (item.name == current.name && previous.name != current.name) {
          errorText = "Tag name already taken";
          return false;
        }
      }
    }
    errorText = null;
    return true;
  }
}
