import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:tuple/tuple.dart';

import '../theme/tabbed_view_theme.dart';
import '../viewmodel/album/album_viewmodel.dart';
import '../viewmodel/app_page_path.dart';
import '../viewmodel/homepage_viewmodel.dart';
import '../viewmodel/tag_templates_viewmodel.dart';
import 'app_tab.dart';

/// Root view of the app on PC that displays one to multiple tabs.
class Host extends StatefulWidget {
  /// View model of home page is single-instanced.
  final homepageViewModel = HomePageViewModel();
  final tagTemplates = TagTemplatesViewModel();

  Host({Key? key}) : super(key: key);

  @override
  State<Host> createState() => _HostState();
}

class _HostState extends State<Host> {
  late final TabbedViewController _tabbedViewController;

  /// Focus node used to receive `Ctrl + N` shortcut.
  late final FocusNode _focus;

  /// ID -> (album, path references)
  late final Map<String, Tuple2<AlbumViewModel, Set<String>>> albums;

  @override
  void initState() {
    super.initState();
    albums = {};
    _focus = FocusNode(debugLabel: 'hostScope');
    _tabbedViewController = TabbedViewController([]);
    // initially there should be one tab.
    _newTab();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _newTab() {
    final current = (_tabbedViewController.selectedIndex ?? -1) + 1;
    _tabbedViewController.insertTab(
        current,
        TabData(
            text: const AppPagePath(kind: AppPageKinds.home).displayName,
            content: AppTab(
              interceptPathChange: _interceptPathChange,
              homePageViewModel: widget.homepageViewModel,
              tagTemplates: widget.tagTemplates,
              getAlbumViewModel: _getAlbumViewModel,
              releaseAlbumViewModel: _releaseAlbumViewModel,
            ),
            keepAlive: true));
    _tabbedViewController.selectedIndex = current;
  }

  /// Intercept then accept or reject path changing of a tab.
  ///
  /// An [AppTab] is identified by reference (memory address).
  bool _interceptPathChange(AppPagePath path, AppTab id) {
    switch (path.kind) {
      case AppPageKinds.tagsMgmt:
        // If the path is opened already in another tab,
        // switch to it and reject the change.
        if (!_handleSingletonPage(path, id)) return false;
        break;
      case AppPageKinds.album:
        if (!_handleSingletonPage(path, id)) return false;
        break;
      default:
        break;
    }
    // Otherwise accept and apply the change.
    final tab = _tabbedViewController.tabs.firstWhere((element) => element.content == id);
    tab.value = path;
    tab.text = path.displayName;
    return true;
  }

  void _debugPrintAlbums() {
    print([
      for (var pair in albums.entries) [pair.key, pair.value.item2]
    ]);
  }

  bool _handleSingletonPage(AppPagePath path, AppTab id) {
    final tabIndex = _tabbedViewController.tabs.indexWhere((element) => element.value == path);
    if (tabIndex >= 0) {
      _tabbedViewController.selectedIndex = tabIndex;
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focus);
    // `TabbedView` unexpectedly overrides text style. Here we restore.
    final textStyle = TextStyle(
        decoration: TextDecoration.none,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize);
    return DefaultTextStyle(
        child: CallbackShortcuts(bindings: {
          // `Ctrl + N` => new tab.
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): _newTab,
        }, child: Focus(focusNode: _focus, child: _buildTabbedView(context))),
        style: textStyle);
  }

  TabbedViewTheme _buildTabbedView(BuildContext context) {
    return TabbedViewTheme(
        child: TabbedView(
            controller: _tabbedViewController,
            tabsAreaButtonsBuilder: (context, tabsCount) => [
                  // Button for opening new tab.
                  TabButton(icon: IconProvider.data(Icons.add), onPressed: _newTab),
                ],
            onTabClose: (_, __) {
              // For simplicity, ensure there's always at least one tab.
              if (_tabbedViewController.tabs.isEmpty) {
                _newTab();
              }
            },
            selectToEnableButtons: false),
        data: TheTabbedViewTheme.build(context));
  }

  AlbumViewModel _getAlbumViewModel(String path, String referredBy) {
    var album = albums[path];
    if (album == null) {
      album = Tuple2(AlbumViewModel(path, tagTemplates: widget.tagTemplates), {referredBy});
      albums[path] = album;
    } else {
      album.item2.add(referredBy);
    }
    _debugPrintAlbums();
    return album.item1;
  }

  void _releaseAlbumViewModel(String? path, String referredBy) {
    final Map<String, Tuple2<AlbumViewModel, Set<String>>> targets;
    if (path != null) {
      final album = albums[path];
      targets = album == null ? {} : {path: album};
    } else {
      targets = albums;
    }
    for (final pair in targets.entries.toList()) {
      final album = pair.value;
      album.item2.remove(referredBy);
      if (album.item2.isEmpty) {
        album.item1.dispose();
        albums.remove(pair.key);
      }
    }
    _debugPrintAlbums();
  }
}
