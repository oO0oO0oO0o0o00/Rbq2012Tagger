import 'package:flutter/material.dart';
import 'package:tagger/viewmodel/album/album_viewmodel.dart';

import '../model/global/model.dart';
import '../viewmodel/album/album_arguments.dart';
import '../viewmodel/app_page_path.dart';
import '../viewmodel/homepage_viewmodel.dart';
import '../viewmodel/tag_templates_viewmodel.dart';
import 'album/album_page.dart';
import 'homepage/homepage.dart';
import 'tags_mgmt/tags_mgmt_page.dart';

/// A tab with its own navigation stack, like a browser tab.
class AppTab extends StatelessWidget {
  final HomePageViewModel homePageViewModel;
  final TagTemplatesViewModel tagTemplates;
  final bool Function(AppPagePath path, AppTab me) interceptPathChange;
  final AlbumViewModel Function(String path, String referredBy) getAlbumViewModel;
  final void Function(String? path, String referredBy) releaseAlbumViewModel;

  const AppTab(
      {Key? key,
      required this.interceptPathChange,
      required this.homePageViewModel,
      required this.tagTemplates,
      required this.getAlbumViewModel,
      required this.releaseAlbumViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: Theme.of(context),
        routes: {
          MyHomePage.routeName: (context) => MyHomePage(
              onOpen: (path) => _handleOpen(context, path),
              onOpenTagsMgmt: () => _handleOpenTagsMgmt(context, false),
              viewModel: homePageViewModel),
          AlbumPage.routeName: (routeContext) => AlbumPage(
                arguments: (ModalRoute.of(routeContext)!.settings.arguments as AlbumArguments),
                tagTemplates: tagTemplates,
                homePageViewModel: homePageViewModel,
                getViewModel: getAlbumViewModel,
                onFailure: (BuildContext context) =>
                    interceptPathChange(const AppPagePath(kind: AppPageKinds.home), this),
                onOpened: (path) {
                  homePageViewModel.addRecent(RecentAlbum(path, lastOpened: DateTime.now(), pinned: false));
                },
                releaseAlbumViewModel: releaseAlbumViewModel,
              ),
          TagsMgmtPage.routeName: (context) =>
              TagsMgmtPage(onClose: () => _handleCloseTagsMgmt(context), tagTemplates: tagTemplates)
        },
      );

  void _handleOpen(BuildContext context, String path) {
    if (!interceptPathChange(AppPagePath(kind: AppPageKinds.album, path: path), this)) return;
    Navigator.pushReplacementNamed(context, AlbumPage.routeName, arguments: AlbumArguments(path: path));
  }

  void _handleOpenTagsMgmt(BuildContext context, bool newTab) {
    if (!interceptPathChange(const AppPagePath(kind: AppPageKinds.tagsMgmt), this)) return;
    Navigator.pushNamed(context, TagsMgmtPage.routeName);
  }

  void _handleCloseTagsMgmt(BuildContext context) {
    if (!interceptPathChange(const AppPagePath(kind: AppPageKinds.home), this)) {
      return;
    }
    Navigator.pop(context);
  }
}
