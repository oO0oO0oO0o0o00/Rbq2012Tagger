import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/album/album_item_viewmodel.dart';
import '../../viewmodel/album/album_viewmodel.dart';
import '../../viewmodel/tag_templates_viewmodel.dart';
import '../commons/tag_view.dart';

/// The view for album item (picture).
///
/// The picture and its name are displayed.
/// Tags are shown above. (TODO: handle too many tags)
/// Selected and hovered items are highlighted.
/// Click event is listened and sent to [AlbumViewModel].
class AlbumItemView extends StatelessWidget {
  final AlbumItemViewModel viewModel;
  // final int index;
  // final AlbumViewModel albumViewModel;
  final void Function() onClick;
  final void Function(String) removeTag;
  const AlbumItemView(
      {Key? key,
      required this.viewModel,
      required this.onClick,
      required this.removeTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
          onTap: onClick,
          hoverColor: Theme.of(context).primaryColor.withAlpha(70),
          mouseCursor: SystemMouseCursors.basic,
          child: ChangeNotifierProvider.value(
              value: viewModel,
              child: Consumer<AlbumItemViewModel>(
                  builder: (context, item, child) =>
                      _buildBody(context, item, child!),
                  // The core part of the view is independent to selected state
                  // and is therefore statically built without builder.
                  child: _buildCore()))),
    );
  }

  Container _buildBody(
      BuildContext context, AlbumItemViewModel item, Widget child) {
    final bottom = Text(viewModel.name, overflow: TextOverflow.ellipsis);
    final color = Theme.of(context).primaryColor;
    final borderColor = item.selected
        ? color
        : (item.singleSelected ? color.withAlpha(128) : Colors.transparent);
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: borderColor),
            color: item.selected ? color : Colors.transparent),
        child: Column(
          children: [
            child,
            item.selected
                ? ColorFiltered(
                    colorFilter: _invertedColorFilter, child: bottom)
                : bottom
          ],
        ));
  }

  Widget _buildCore() {
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
                  value: viewModel, child: _buildTagsView()),
            ])));
  }

  Widget _buildTagsView() => Consumer<TagTemplatesViewModel>(
        builder: (context, tagTemplates, child) => Consumer<AlbumItemViewModel>(
            builder: (context, itemViewModel, child) {
          itemViewModel.updateTagTemplates(tagTemplates);
          return Tags(
            itemCount: itemViewModel.getTagsCount(),
            itemBuilder: (index) {
              final item = itemViewModel.getTagAt(index);
              return TagView(item: item, onClose: removeTag);
            },
          );
        }),
      );
}

const _invertedColorFilter = ColorFilter.matrix([
  -1, 0, 0, 0, 255, //
  0, -1, 0, 0, 255, //
  0, 0, -1, 0, 255, //
  0, 0, 0, 1, 0, //
]);
