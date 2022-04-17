import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../../util/platform.dart';
import '../../viewmodel/album/album_arguments.dart';
import '../../viewmodel/album/album_viewmodel.dart';
import 'package:provider/provider.dart';

import '../commons/dialogs.dart';
import 'album_body.dart';
import 'album_page_sidebar.dart';
import 'bulk_tags_view.dart';
import 'sort_icon.dart';
import 'tag_templates_view.dart';

class AlbumPage extends StatefulWidget {
  final String path;
  final void Function() onOpened;
  final void Function() onFailure;

  AlbumPage({Key? key, required AlbumArguments arguments})
      : path = arguments.path,
        onOpened = arguments.onOpened,
        onFailure = arguments.onFailure,
        super(key: key);

  static const routeName = '/album';

  @override
  State<AlbumPage> createState() => AlbumState();
}

class AlbumState extends State<AlbumPage> with SingleTickerProviderStateMixin {
  late final AlbumViewModel model = AlbumViewModel(widget.path);
  late final _tabController = TabController(length: 2, vsync: this);
  bool _loadingDB = false;
  bool _loadingContents = false;
  bool _showSideTab = true;
  int _sideTabIndex = 0;
  final _sideTabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadDB(context);
    _loadContents(context);
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: model,
      child: isPC() ? _buildForPC(context) : _buildForMobile(context));

  Widget _buildForPC(BuildContext context) => Material(child: _buildBody(true));

  Widget _buildForMobile(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Consumer<AlbumViewModel>(
            builder: (context, viewModel, child) =>
                Text(viewModel.pathForDisplay)),
        actions: const [SortIcon()],
      ),
      body: _buildBody(false));

  Widget _buildBody(bool isPC) {
    final sideTab = TabBarView(
      key: _sideTabKey,
      controller: _tabController,
      children: [
        TagTemplatesView(
          onClickTag: _onClickTag,
        ),
        BulkTagsView(
          onClickTag: (tag) {},
        ),
      ],
    );
    return Stack(children: [
      Row(children: [
        AlbumPageSidebar(
          selectedIndex: _sideTabIndex,
          tabIcons: const [
            Icon(Icons.bookmarks_outlined),
            Icon(Icons.fact_check_outlined)
          ],
          actionIcons: const [SortIcon(offset: Offset(64, 0))],
          onSelectSideTab: _onSelectTab,
        ),
        Expanded(
          child: _showSideTab
              ? MultiSplitView(
                  children: [sideTab, const AlbumBody()],
                  initialWeights: const [.2, .8],
                )
              : Stack(children: [
                  Offstage(
                    offstage: true,
                    child: sideTab,
                  ),
                  const AlbumBody()
                ]),
        ),
      ]),
      if (_loadingDB || _loadingContents) const LinearProgressIndicator(),
    ]);
  }

  Future<void> _loadContents(BuildContext context) async {
    if (_loadingContents) return;
    final album = model;
    setState(() => _loadingContents = true);
    await album.loadContents();
    setState(() => _loadingContents = false);
  }

  Future<void> _loadDB(BuildContext context) async {
    final album = model;
    if (_loadingDB || album.dbReady) return;
    setState(() => _loadingDB = true);
    if (!await album.isManaged()) {
      if (await showConfirmationDialog(context,
              title: 'Create Album',
              content:
                  'The selected folder is currently not an managed album. Create one?') !=
          true) {
        widget.onFailure();
        return;
      }
    }
    widget.onOpened();
    await album.initDatabase();
    setState(() => _loadingDB = false);
  }

  void _onClickTag(String tag) => model.addTagToSelected(tag);

  void _onSelectTab(int index) {
    if (index == _sideTabIndex) {
      setState(() => _showSideTab = !_showSideTab);
    } else {
      setState(() {
        _showSideTab = true;
        _sideTabIndex = index;
      });
      _tabController.index = index;
    }
  }
}
