import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../util/keyboard.dart';
import '../../viewmodel/album/album_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/album/tag_templates_viewmodel.dart';
import 'album_item_view.dart';

class AlbumBody extends StatefulWidget {
  const AlbumBody({
    Key? key,
  }) : super(key: key);

  @override
  State<AlbumBody> createState() => _AlbumBodyState();
}

class _AlbumBodyState extends State<AlbumBody> {
  late final FocusNode focus;

  static const itemHeight = 240;
  bool isControlPressed = false;
  bool isShiftPressed = false;
  int nCols = 0;

  late final ScrollController _scrollController;

  @override
  initState() {
    super.initState();
    focus = FocusNode(debugLabel: 'albumScope');
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final viewModel = context.read<AlbumViewModel>();
      viewModel.visibleIndex =
          (_scrollController.position.pixels / itemHeight).round() * nCols;
    });
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).requestFocus(focus);
    return Focus(
        focusNode: focus,
        autofocus: true,
        onKey: _onKey,
        child: Consumer<AlbumViewModel>(
            builder: (context, albumViewModel, child) => LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  nCols = max(1, (constraints.maxWidth / 320).floor());
                  albumViewModel.selectionController.numCols = nCols;
                  handleScrollTo(albumViewModel, constraints);
                  return GridView.builder(
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: nCols,
                          childAspectRatio:
                              constraints.maxWidth / nCols / itemHeight),
                      itemBuilder: (context, index) {
                        var widget = AlbumItemView(
                            albumViewModel: albumViewModel, index: index);
                        return widget;
                      },
                      itemCount: albumViewModel.getItemsCount());
                })));
  }

  void handleScrollTo(
      AlbumViewModel albumViewModel, BoxConstraints constraints) {
    if (!_scrollController.hasClients) return;
    final int animateTarget;
    if (albumViewModel.movingSelection) {
      animateTarget = albumViewModel.selectionController.singleSelection;
    } else {
      animateTarget = albumViewModel.visibleIndex;
    }
    final double animateOffset =
        (animateTarget ~/ nCols).toDouble() * itemHeight;
    final double? animateTo;
    final scrollPosition = _scrollController.position.pixels;
    if (animateOffset < scrollPosition) {
      animateTo = animateOffset - itemHeight / 2;
    } else if (animateOffset + itemHeight >
        _scrollController.position.pixels + constraints.maxHeight) {
      animateTo = animateOffset - constraints.maxHeight + itemHeight * 3 / 2;
    } else {
      animateTo = null;
    }
    if (animateTo != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        await _scrollController.animateTo(animateTo!,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
        if (animateTarget ==
            albumViewModel.selectionController.singleSelection) {
          albumViewModel.movingSelection = false;
        }
      });
    }
  }

  KeyEventResult _onKey(FocusNode n, RawKeyEvent e) {
    final viewModel = context.read<AlbumViewModel>();
    final selectionHandled = viewModel.selectionController.handleKey(e);

    if (selectionHandled != KeyEventResult.ignored) {
      viewModel.movingSelection = true;
      return selectionHandled;
    }

    if (e is! RawKeyDownEvent) return KeyEventResult.ignored;

    final shortcut = getSingleKeyShortcut(e.logicalKey.keyLabel);
    if (shortcut == null) return KeyEventResult.ignored;
    final tag = viewModel.tagTemplatesViewModel.getByShortcut(shortcut);
    if (tag == null) return KeyEventResult.ignored;
    if (e.isAltPressed) {
      viewModel.removeTagFromSelected(tag.name);
    } else {
      viewModel.addTagToSelected(tag.name);
    }
    if (e.isShiftPressed) {
      viewModel.selectionController
          .handleMovement(1, isControlPressed: false, isShiftPressed: false);
      viewModel.movingSelection = true;
    }
    return KeyEventResult.skipRemainingHandlers;
  }
}
