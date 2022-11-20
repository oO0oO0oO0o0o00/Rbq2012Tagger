import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import '../../model/global/batch_action.dart';
import '../../viewmodel/homepage_viewmodel.dart';
import '../../model/global/search_options.dart';
import '../../util/platform.dart';
import '../../viewmodel/album/album_arguments.dart';
import '../../viewmodel/album/album_viewmodel.dart';
import '../../viewmodel/tag_templates_viewmodel.dart';
import '../commons/dialogs.dart';
import 'action_icons/action_icon.dart';
import 'action_icons/filter_icon.dart';
import 'action_icons/sort_icon.dart';
import 'album_body.dart';
import 'album_page_sidebar.dart';
import 'sidetabs/bulk_tags_view.dart';
import 'sidetabs/search_view.dart';
import 'sidetabs/tag_templates_card_view.dart';

class AlbumPage extends StatefulWidget {
  final String path;
  final TagTemplatesViewModel tagTemplates;
  final HomePageViewModel homePageViewModel;
  final void Function(String path) onOpened;
  final void Function(BuildContext context) onFailure;
  final AlbumViewModel Function(String path, String referredBy) getViewModel;
  final void Function(String path, String referredBy) releaseAlbumViewModel;

  AlbumPage(
      {Key? key,
      required AlbumArguments arguments,
      required this.tagTemplates,
      required this.homePageViewModel,
      required this.getViewModel,
      required this.onOpened,
      required this.onFailure,
      required this.releaseAlbumViewModel})
      : path = arguments.path,
        super(key: key);

  static const routeName = '/album';

  @override
  State<AlbumPage> createState() => AlbumState();
}

class AlbumState extends State<AlbumPage> with SingleTickerProviderStateMixin {
  late final AlbumViewModel viewModel;
  late final _tabController = TabController(length: 3, vsync: this);
  bool _showSideTab = true;
  int _sideTabIndex = 0;
  final _sideTabKey = GlobalKey();
  final _bodyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    viewModel = widget.getViewModel(widget.path, widget.path);
    _load(context);
  }

  @override
  void dispose() {
    widget.releaseAlbumViewModel(widget.path, widget.path);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: widget.tagTemplates,
      child: ChangeNotifierProvider.value(
        value: widget.homePageViewModel,
        child: ChangeNotifierProvider.value(
            value: viewModel,
            builder: (context, child) =>
                isPC() ? _buildForPC(context) : _buildForMobile(context)),
      ));

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
              actionIcons: [
                if (Provider.of<AlbumViewModel>(context).filter != null)
                  const FilterIcon(offset: Offset(64, 0)),
                ActionIcon(onConfirmed: _applyAction),
                const SortIcon(offset: Offset(64, 0))
              ],
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
          if (context.read<AlbumViewModel>().loading)
            const LinearProgressIndicator(),
        ]);
      }(true));

  Widget _buildForMobile(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Consumer<AlbumViewModel>(
            builder: (context, viewModel, child) =>
                Text(viewModel.pathForDisplay)),
        actions: [ActionIcon(onConfirmed: _applyAction), const SortIcon()],
      ),
      body: AlbumBody(key: _bodyKey));

  Future<void> _load(BuildContext context) async {
    if (viewModel.loading || viewModel.dbReady) return;
    if (!await viewModel.isManaged()) {
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
    await viewModel.loadContents();
    widget.onOpened(widget.path);
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

  bool _applyAction(BatchAction action) {
    if (viewModel.loading) return false;
    viewModel.performBatchAction(
        action, widget.getViewModel, widget.releaseAlbumViewModel);
    return true;
  }
}
// TODO: reduce reference after page closed. Dispose if owner page closed or reference nullified.