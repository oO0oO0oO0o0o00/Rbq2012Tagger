import 'package:flutter/foundation.dart';

import '../../model/global/model.dart';
import '../../service/tag_templates_service.dart';

class TagTemplatesViewModel with ChangeNotifier {
  List<TagTemplate>? _cache;
  Map<String, TagTemplate>? _indexByName;
  Map<String, TagTemplate>? _indexByShortcut;

  int getItemsCount() {
    final cache = _cache;
    if (cache != null) return cache.length;
    _loadCache();
    return 0;
  }

  TagTemplate getItem(int index) => _cache![index];

  Future<List<TagTemplate>> _loadCache({bool reload = false}) async {
    final cache = _cache;
    if (!reload && cache != null) return cache;
    final ret = _cache = await TagTemplatesService.getAll();
    _indexByName = Map.fromEntries(ret.map((e) => MapEntry(e.name, e)));
    _indexByShortcut = Map.fromEntries(ret
        .where((element) => element.shortcut != null)
        .map((e) => MapEntry(e.shortcut!, e)));
    notifyListeners();
    return ret;
  }

  TagTemplate? getByName(String tagName) {
    final lookup = _indexByName;
    if (lookup != null) return lookup[tagName];
    _loadCache();
    return null;
  }

  TagTemplate? getByShortcut(String shortcut) {
    final lookup = _indexByShortcut;
    if (lookup != null) return lookup[shortcut];
    _loadCache();
    return null;
  }
}
