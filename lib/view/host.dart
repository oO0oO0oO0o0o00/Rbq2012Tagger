import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabbed_view/tabbed_view.dart';

import '../theme/tabbed_view_theme.dart';
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

  @override
  void initState() {
    super.initState();
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
                tagTemplates: widget.tagTemplates),
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
    final tab = _tabbedViewController.tabs
        .firstWhere((element) => element.content == id);
    tab.value = path;
    tab.text = path.displayName;
    return true;
  }

  bool _handleSingletonPage(AppPagePath path, AppTab id) {
    final tabIndex = _tabbedViewController.tabs
        .indexWhere((element) => element.value == path);
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
        color: Theme.of(context).textTheme.bodyText1?.color,
        fontSize: Theme.of(context).textTheme.bodyText1?.fontSize);
    return DefaultTextStyle(
        child: CallbackShortcuts(bindings: {
          // `Ctrl + N` => new tab.
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
                  // Button for opening new tab.
                  TabButton(
                      icon: IconProvider.data(Icons.add), onPressed: _newTab),
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
}
