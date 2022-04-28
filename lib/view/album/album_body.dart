import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:flutter/material.dart';
import '../../util/keyboard.dart';
import '../../util/platform.dart';
import '../../viewmodel/album/album_viewmodel.dart';
import 'package:provider/provider.dart';

import 'album_item_view.dart';

/// Body of the Album view, containing a grid of album items.
class AlbumBody extends StatefulWidget {
  const AlbumBody({
    Key? key,
  }) : super(key: key);

  @override
  State<AlbumBody> createState() => _AlbumBodyState();
}

class _AlbumBodyState extends State<AlbumBody> {
  // Focus node for receiving keyboard shortcuts.
  late final FocusNode _focus;
  late final ScrollController _scrollController;

  @override
  initState() {
    super.initState();
    _focus = FocusNode(debugLabel: 'albumScope');
    _scrollController =
        context.read<AlbumViewModel>().controller.scrollController;
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(_focus);
    return Focus(
        focusNode: _focus,
        autofocus: true,
        // Keyboard shortcuts (both navigation and tags) are listened here.
        onKey: (node, e) =>
            context.read<AlbumViewModel>().controller.handleKey(node, e),
        child: Consumer<AlbumViewModel>(
            builder: (context, albumViewModel, child) => LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  albumViewModel.controller.handleResize(
                      constraints.maxWidth, constraints.maxHeight);
                  return isPC()
                      ? Listener(
                          // There's no mean to cancel the scroll wheel event
                          // so both scrolling and zooming must be handled here
                          // altogether.
                          onPointerSignal:
                              albumViewModel.controller.handlePointerSignal,
                          child: ImprovedScrolling(
                            scrollController: _scrollController,
                            enableMMBScrolling: true,
                            mmbScrollConfig: const MMBScrollConfig(
                              customScrollCursor: DefaultCustomScrollCursor(),
                            ),
                            child: _buildGrid(albumViewModel, constraints),
                          ),
                        )
                      : _buildGrid(albumViewModel, constraints);
                })));
  }

  Widget _buildGrid(AlbumViewModel viewModel, BoxConstraints constraints) {
    return GridView.builder(
        controller: _scrollController,
        // For PC, disable scroll handling here.
        // Instead, the grid is wrapped in a `Listener` and scroll events
        // are processed there.
        physics: isPC() ? const NeverScrollableScrollPhysics() : null,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: viewModel.controller.numCols,
            // Fixed height & preferred aspect ratio
            // => flexible width => calculated real aspect
            childAspectRatio: constraints.maxWidth /
                viewModel.controller.numCols /
                viewModel.controller.itemHeight),
        itemBuilder: (context, index) {
          final itemViewModel = viewModel.getItem(index);
          return AlbumItemView(
            viewModel: itemViewModel,
            onClick: () {
              viewModel.controller.handleItemClick(index,
                  isControlPressed: isControlPressed(),
                  isShiftPressed: isShiftPressed());
            },
            removeTag: (String tag) =>
                viewModel.controller.removeTagFromItem(itemViewModel, tag),
          );
        },
        itemCount: viewModel.getItemsCount());
  }
}
