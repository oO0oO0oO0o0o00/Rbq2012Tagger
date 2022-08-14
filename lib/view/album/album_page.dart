import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:tagger/model/global/model.dart';
import '../../util/platform.dart';
import '../../viewmodel/album/album_arguments.dart';
import '../../viewmodel/album/album_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/tag_templates_viewmodel.dart';
import '../commons/dialogs.dart';
import 'album_body.dart';
import 'album_page_sidebar.dart';
import 'sidetabs/bulk_tags_view.dart';
import 'sidetabs/search_view.dart';
import 'sort_icon.dart';
import 'sidetabs/tag_templates_card_view.dart';

class AlbumPage extends StatefulWidget {
  final String path;
  final TagTemplatesViewModel tagTemplates;
  final void Function() onOpened;
  final void Function(BuildContext context) onFailure;

  AlbumPage(
      {Key? key, required AlbumArguments arguments, required this.tagTemplates})
      : path = arguments.path,
        onOpened = arguments.onOpened,
        onFailure = arguments.onFailure,
        super(key: key);

  static const routeName = '/album';

  @override
  State<AlbumPage> createState() => AlbumState();
}

class AlbumState extends State<AlbumPage> with SingleTickerProviderStateMixin {
  late final AlbumViewModel viewModel;
  late final _tabController = TabController(length: 3, vsync: this);
  bool _loadingDB = false;
  bool _loadingContents = false;
  bool _showSideTab = true;
  int _sideTabIndex = 0;
  final _sideTabKey = GlobalKey();
  final _bodyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    viewModel = AlbumViewModel(widget.path, tagTemplates: widget.tagTemplates);
    _loadDB(context);
    _loadContents(context);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: widget.tagTemplates,
        child: ChangeNotifierProvider.value(
            value: viewModel,
            child: isPC() ? _buildForPC(context) : _buildForMobile(context)),
      );

  Widget _buildForPC(BuildContext context) => Material(
          child: (bool isPC) {
        // Side tab can be hidden. When hidden, still build it
        // and put it some where or its state would be recycled.
        final sideTab = TabBarView(
          key: _sideTabKey,
          controller: _tabController,
          children: [
            TagTemplatesCardView(
              onClickTag: _onClickTag,
            ),
            BulkTagsView(
              onClickTag: (tag) {},
            ),
            SearchView(onSetFilter: _onSetFilter)
          ],
        );
        // A stack is used to show progress bar above.
        return Stack(children: [
          // Basically it's Row([side bar, MultiSplitView([side tab, body])]).
          Row(children: [
            AlbumPageSidebar(
              selectedIndex: _sideTabIndex,
              tabIcons: const [
                Icon(Icons.bookmarks_outlined),
                Icon(Icons.fact_check_outlined),
                Icon(Icons.search)
              ],
              actionIcons: const [SortIcon(offset: Offset(64, 0))],
              onSelectSideTab: _onSelectTab,
            ),
            Expanded(
              // `MultiSplitView` does not play well with `Offstage`.
              child: _showSideTab
                  ? MultiSplitView(
                      children: [sideTab, AlbumBody(key: _bodyKey)],
                      initialWeights: const [.2, .8],
                    )
                  : Stack(children: [
                      Offstage(offstage: true, child: sideTab),
                      AlbumBody(key: _bodyKey)
                    ]),
            ),
          ]),
          if (_loadingDB || _loadingContents) const LinearProgressIndicator(),
        ]);
      }(true));

  Widget _buildForMobile(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Consumer<AlbumViewModel>(
            builder: (context, viewModel, child) =>
                Text(viewModel.pathForDisplay)),
        actions: const [SortIcon()],
      ),
      body: AlbumBody(key: _bodyKey));

  Future<void> _loadContents(BuildContext context) async {
    if (_loadingContents) return;
    final album = viewModel;
    setState(() => _loadingContents = true);
    await album.loadContents();
    setState(() => _loadingContents = false);
  }

  Future<void> _loadDB(BuildContext context) async {
    final album = viewModel;
    if (_loadingDB || album.dbReady) return;
    setState(() => _loadingDB = true);
    if (!await album.isManaged()) {
      if (await showConfirmationDialog(context,
              title: 'Create Album',
              content:
                  'The selected folder is currently not an managed album. Create one?') !=
          true) {
        widget.onFailure(context);
        return;
      }
    }
    await viewModel.openDatabase();
    widget.onOpened();
    setState(() => _loadingDB = false);
  }

  void _onClickTag(String tag) => viewModel.controller.addTagToSelected(tag);

  void _onSelectTab(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.index = index;
    });
    if (index == _sideTabIndex) {
      setState(() => _showSideTab = !_showSideTab);
    } else {
      setState(() {
        _showSideTab = true;
        _sideTabIndex = index;
      });
    }
  }

  void _onSetFilter(SearchOptions? filter) {
    viewModel.filter = filter;
  }
}
