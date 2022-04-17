import 'package:path/path.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:tagger/view/album/album_page.dart';
import 'package:tagger/view/homepage/homepage.dart';
import 'package:tagger/viewmodel/album/album_arguments.dart';

import '../model/global/model.dart';
import '../theme/tabbed_view_theme.dart';
import '../viewmodel/homepage_viewmodel.dart';

class Host extends StatefulWidget {
  final homepageViewModel = HomePageViewModel();

  Host({Key? key}) : super(key: key);

  @override
  State<Host> createState() => _HostState();
}

class _HostState extends State<Host> {
  static const newTabName = 'Get Started';
  late final TabbedViewController _tabbedViewController;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode(debugLabel: 'hostScope');
    _tabbedViewController = TabbedViewController([]);
    _newTab();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _newTab() {
    final current = _tabbedViewController.selectedIndex ?? -1;
    _tabbedViewController.insertTab(
        current + 1,
        TabData(
            text: newTabName,
            content: Tab(
                interceptPathChange: _interceptPathChange,
                homePageViewModel: widget.homepageViewModel),
            keepAlive: true));
    _tabbedViewController.selectedIndex = current + 1;
  }

  bool _interceptPathChange(String? path, Tab id) {
    if (path != null) {
      final tabIndex = _tabbedViewController.tabs
          .indexWhere((element) => element.value == path);
      if (tabIndex >= 0) {
        _tabbedViewController.selectedIndex = tabIndex;
        return false;
      }
    }
    final tab = _tabbedViewController.tabs
        .firstWhere((element) => element.content == id);
    tab.value = path;
    tab.text = path == null ? newTabName : basename(path);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focus);
    final textStyle = TextStyle(
        decoration: TextDecoration.none,
        color: Theme.of(context).textTheme.bodyText1?.color,
        fontSize: Theme.of(context).textTheme.bodyText1?.fontSize);
    return DefaultTextStyle(
        child: CallbackShortcuts(bindings: {
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
              _newTab,
        }, child: Focus(focusNode: _focus, child: _buildTabbedView(context))),
        style: textStyle);
  }

  TabbedViewTheme _buildTabbedView(BuildContext context) {
    return TabbedViewTheme(
        child: TabbedView(
            controller: _tabbedViewController,
            tabsAreaButtonsBuilder: (context, tabsCount) => [
                  TabButton(
                      icon: IconProvider.data(Icons.add), onPressed: _newTab),
                ],
            onTabClose: (_, __) {
              if (_tabbedViewController.tabs.isEmpty) {
                _newTab();
              }
            },
            selectToEnableButtons: false),
        data: TheTabbedViewTheme.build(context));
  }
}

class Tab extends StatelessWidget {
  final HomePageViewModel homePageViewModel;
  final bool Function(String? path, Tab me) interceptPathChange;

  const Tab(
      {Key? key,
      required this.interceptPathChange,
      required this.homePageViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        routes: {
          MyHomePage.routeName: (context) => MyHomePage(
              onOpen: (path) => _handleOpen(context, path),
              viewModel: homePageViewModel),
          AlbumPage.routeName: (routeContext) => AlbumPage(
              arguments: (ModalRoute.of(routeContext)!.settings.arguments
                  as AlbumArguments))
        },
      );

  void _handleOpen(BuildContext context, String path) {
    if (!interceptPathChange(path, this)) return;
    Navigator.pushReplacementNamed(context, AlbumPage.routeName,
        arguments: AlbumArguments(
            path: path,
            onOpened: () => homePageViewModel.addRecent(
                RecentAlbum(path, lastOpened: DateTime.now(), pinned: false)),
            onFailure: () => interceptPathChange(null, this)));
  }
}
