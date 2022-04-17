import 'package:flutter/foundation.dart';
import 'package:tagger/model/global/model.dart';
import 'package:tagger/service/recent_albums_service.dart';

class HomePageViewModel with ChangeNotifier {
  List<RecentAlbum>? _recents;
  static const _maxRecentAlbums = 15;

  Future<void> _loadRecents({bool reload = false}) async {
    if (_recents != null && !reload) return;
    _recents = await RecentAlbumsService.listRecent(_maxRecentAlbums);
    notifyListeners();
  }

  RecentAlbum? getItem(int index) {
    final recents = _recents;
    if (recents != null) {
      return recents[index];
    }
    _loadRecents();
    return null;
  }

  int getItemsCount() {
    final recents = _recents;
    if (recents != null) {
      return recents.length;
    }
    _loadRecents();
    return 0;
  }

  Future<void> addRecent(RecentAlbum item) async {
    await RecentAlbumsService.insert(item, _maxRecentAlbums);
    await _loadRecents(reload: true);
  }

  Future<void> removeItem(RecentAlbum item) async {
    await RecentAlbumsService.remove(item);
    await _loadRecents(reload: true);
  }

  Future<void> pinOrUnpinItem(RecentAlbum item) async {
    await RecentAlbumsService.updatePinnedState(item);
    await _loadRecents(reload: true);
  }
}
