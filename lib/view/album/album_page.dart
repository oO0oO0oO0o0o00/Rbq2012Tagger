import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:tabbed_view/tabbed_view.dart';
import 'package:tagger/model/global/model.dart';
import 'package:tagger/service/tutorial_service.dart';
import 'package:tuple/tuple.dart';
import '../../model/global/batch_action.dart';
import '../../viewmodel/homepage_viewmodel.dart';
import '../../model/global/search_options.dart';
import '../../util/platform.dart';
import '../../viewmodel/album/album_arguments.dart';
import '../../viewmodel/album/album_viewmodel.dart';
import '../../viewmodel/tag_templates_viewmodel.dart';
import '../commons/dialogs.dart';
import '../commons/file_conflict_dialog.dart';
import 'action_icons/action_icon.dart';
import 'action_icons/filter_icon.dart';
import 'action_icons/sort_icon.dart';
import 'album_body.dart';
import 'album_page_sidebar.dart';
import 'sidetabs/bulk_tags_view.dart';
import 'sidetabs/search_view.dart';
import 'sidetabs/sidetab_tooltip.dart';
import 'sidetabs/tag_templates_card_view.dart';

class AlbumPage extends StatefulWidget {
  final String path;
  final TagTemplatesViewModel tagTemplates;
  final HomePageViewModel homePageViewModel;
  final void Function(String path) onOpened;
  final void Function(BuildContext context) onFailure;
  final AlbumViewModel Function(String path, String referredBy) getViewModel;
  final void Function(String? path, String referredBy) releaseAlbumViewModel;

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
  // Focus node for receiving keyboard shortcuts.
  late final FocusNode _focus;
  late final _tabController = TabController(length: 3, vsync: this);
  bool _showSideTab = true;
  int _sideTabIndex = 0;
  final _sideTabKey = GlobalKey();
  final _bodyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focus = FocusNode(debugLabel: 'albumScope');
    viewModel = widget.getViewModel(widget.path, widget.path);
    _load(context);
  }

  @override
  void dispose() {
    _focus.dispose();
    widget.releaseAlbumViewModel(null, widget.path);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
      value: widget.tagTemplates,
      child: ChangeNotifierProvider.value(
        value: widget.homePageViewModel,
        child: ChangeNotifierProvider.value(
            value: viewModel, builder: (context, child) => isPC() ? _buildForPC(context) : _buildForMobile(context)),
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
        final body = AlbumBody(key: _bodyKey);
        // A stack is used to show progress bar above.
        final listenedViewModel = Provider.of<AlbumViewModel>(context);
        return Stack(children: [
          // Basically it's Row([side bar, MultiSplitView([side tab, body])]).
          Row(children: [
            AlbumPageSidebar(
              selectedIndex: _sideTabIndex,
              tabIcons: const [
                Tuple2("templates", Icon(Icons.bookmarks_outlined)),
                Tuple2("tags of selections", Icon(Icons.fact_check_outlined)),
                Tuple2("filter", Icon(Icons.search)),
              ],
              actionIcons: [
                if (listenedViewModel.controller.selections.isNotEmpty) _buildDeleteIcon(),
                if (listenedViewModel.filter != null) const FilterIcon(offset: Offset(64, 0)),
                if (listenedViewModel.controller.selections.isNotEmpty)
                  ActionIcon(onConfirmed: _applyAction, currentPath: widget.path),
                const SortIcon(offset: Offset(64, 0))
              ],
              onSelectSideTab: _onSelectTab,
            ),
            Expanded(
                // `MultiSplitView` does not play well with `Offstage`.
                child:
                    // _showSideTab
                    // ?
                    MultiSplitView(
              initialAreas: [Area(weight: 0.2), Area(weight: 0.8)],
              children: [sideTab, body],
            )
                // :
                // Stack(children: [Offstage(offstage: true, child: sideTab), body]),
                ),
          ]),
          if (context.read<AlbumViewModel>().loading) const LinearProgressIndicator(),
        ]);
      }(true));

  Widget _buildDeleteIcon() => SidetabTooltip(
        message: "delete",
        child: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: _handleDeleteAction,
        ),
      );

  Widget _buildForMobile(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Consumer<AlbumViewModel>(builder: (context, viewModel, child) => Text(viewModel.pathForDisplay)),
        actions: [ActionIcon(onConfirmed: _applyAction, currentPath: widget.path), const SortIcon()],
      ),
      body: AlbumBody(key: _bodyKey));

  Future<void> _load(BuildContext context) async {
    if (viewModel.loading || viewModel.dbReady) return;
    if (!await viewModel.isManaged()) {
      if (await showConfirmationDialog(context,
              title: 'Create Album', content: 'The selected folder is currently not an managed album. Create one?') !=
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
      action,
      getAlbumViewModel: widget.getViewModel,
      releaseAlbumViewModel: widget.releaseAlbumViewModel,
      conflictResolver: ((conflicts) => showFileConflictResolvingDialog(context, conflicts)),
    );
    if (action.enableMoveCopyAction) {
      widget.homePageViewModel.addRecent(RecentAlbum(action.path!, lastOpened: DateTime.now(), pinned: false));
    }
    return true;
  }

  Future<void> _handleDeleteAction() async {
    if (await TutorialService.instance.shouldShow(TutorialService.kDeletionNotice, 2, increase: true)) {
      await showConfirmationDialog(context,
          content: "Deleted items would be moved to the recycle folder of the album, "
              "along with a json file containing their tags. "
              "You can manage deleted items with the file browser, "
              "and restore them with scripts.",
          title: "Deletion...",
          hasNegativeButton: false);
    }
    await viewModel.performDeletion();
  }
}
