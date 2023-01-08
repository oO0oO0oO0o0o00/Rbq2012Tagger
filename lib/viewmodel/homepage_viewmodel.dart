import 'package:flutter/foundation.dart';
import '../model/global/model.dart';
import '../service/recent_albums_service.dart';

class HomePageViewModel with ChangeNotifier {
  List<RecentAlbum>? _recentItems;
  static const _maxRecentAlbums = 15;

  Future<void> _loadRecentItems({bool reload = false}) async {
    if (_recentItems != null && !reload) return;
    _recentItems = await RecentAlbumsService.listRecent(_maxRecentAlbums);
    notifyListeners();
  }

  RecentAlbum? getItem(int index) {
    final recentItems = _recentItems;
    if (recentItems != null) {
      return recentItems[index];
    }
    _loadRecentItems();
    return null;
  }

  RecentAlbum? getByPath(String path) {
    final recentItems = _recentItems;
    if (recentItems != null) {
      return recentItems.firstWhere((element) => element.path == path,
          orElse: () =>
              RecentAlbum(path, lastOpened: DateTime.now(), pinned: false));
    }
    _loadRecentItems();
    return null;
  }

  int getItemsCount() {
    final recentItems = _recentItems;
    if (recentItems != null) {
      return recentItems.length;
    }
    _loadRecentItems();
    return 0;
  }

  Future<void> addRecent(RecentAlbum item) async {
    await RecentAlbumsService.insert(item, _maxRecentAlbums);
    await _loadRecentItems(reload: true);
  }

  Future<void> removeItem(RecentAlbum item) async {
    await RecentAlbumsService.remove(item);
    await _loadRecentItems(reload: true);
  }

  Future<void> pinOrUnpinItem(RecentAlbum item) async {
    await RecentAlbumsService.updatePinnedState(item);
    await _loadRecentItems(reload: true);
  }
}
