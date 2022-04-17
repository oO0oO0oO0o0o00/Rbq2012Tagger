import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tags/flutter_tags.dart';
import '../../viewmodel/album/album_item_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/album/album_viewmodel.dart';
import 'album_item_tag_view.dart';

class AlbumItemView extends StatelessWidget {
  final AlbumItemViewModel viewModel;
  final int index;
  final AlbumViewModel albumViewModel;

  AlbumItemView({
    Key? key,
    required this.albumViewModel,
    required this.index,
  })  : viewModel = albumViewModel.getItem(index),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
          onTap: () {
            var keys = RawKeyboard.instance.keysPressed;
            final isControlPressed =
                keys.contains(LogicalKeyboardKey.controlLeft) ||
                    keys.contains(LogicalKeyboardKey.controlRight);
            final isShiftPressed =
                keys.contains(LogicalKeyboardKey.shiftLeft) ||
                    keys.contains(LogicalKeyboardKey.shiftRight);
            albumViewModel.selectionController.handleItemClick(index,
                isControlPressed: isControlPressed,
                isShiftPressed: isShiftPressed);
          },
          hoverColor: Theme.of(context).primaryColor.withAlpha(70),
          mouseCursor: SystemMouseCursors.basic,
          child: ChangeNotifierProvider.value(
              value: viewModel,
              child: Consumer<AlbumItemViewModel>(
                  builder: (context, value, child) {
                    final bottom =
                        Text(viewModel.name, overflow: TextOverflow.ellipsis);
                    return Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 2,
                                color: value.selected
                                    ? Colors.blue
                                    : (value.singleSelected
                                        ? Colors.blue.withAlpha(128)
                                        : Colors.transparent)),
                            color: value.selected
                                ? Colors.blue
                                : Colors.transparent),
                        child: Column(
                          children: [
                            child!,
                            value.selected
                                ? ColorFiltered(
                                    colorFilter: _invertedColorFilter,
                                    child: bottom)
                                : bottom
                          ],
                        ));
                  },
                  child: buildBody()))),
    );
  }

  Widget buildBody() {
    return Expanded(
        child: Container(
            height: double.infinity,
            width: double.infinity,
            padding: const EdgeInsets.all(2),
            child: Stack(fit: StackFit.passthrough, children: [
              FittedBox(
                  clipBehavior: Clip.hardEdge,
                  fit: BoxFit.cover,
                  child: Image.file(File(viewModel.path))),
              ChangeNotifierProvider.value(
                  value: viewModel, child: buildTagsView()),
            ])));
  }

  Widget buildTagsView() {
    return Consumer<AlbumItemViewModel>(
        builder: (context, itemViewModel, child) => Tags(
              itemCount: itemViewModel.getTagsCount(),
              itemBuilder: (index) {
                final item = itemViewModel.getTagAt(index);
                return AlbumItemTagView(
                  item: item,
                  onClose: (String tag) =>
                      albumViewModel.removeTag(viewModel, tag),
                );
              },
            ));
  }
}

const _invertedColorFilter = ColorFilter.matrix([
  -1, 0, 0, 0, 255, //
  0, -1, 0, 0, 255, //
  0, 0, -1, 0, 255, //
  0, 0, 0, 1, 0, //
]);
