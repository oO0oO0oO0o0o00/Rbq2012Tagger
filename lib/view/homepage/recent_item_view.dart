import 'dart:io';

import 'package:flutter/material.dart';

import '../../viewmodel/homepage_viewmodel.dart';
import '../../viewmodel/recent_album_view_model.dart';
import '../commons/dialogs.dart';
import '../commons/simple_list_item.dart';

/// View for a recently opened album.
class RecentItemView extends StatelessWidget {
  const RecentItemView({
    Key? key,
    required this.viewModel,
    required this.item,
    this.onOpen,
  }) : super(key: key);

  final HomePageViewModel viewModel;
  final RecentAlbumViewModel? item;
  final void Function(String path)? onOpen;

  void _deleteItem(BuildContext context) {
    if (item != null) {
      viewModel.removeItem(item!.model);
    }
  }

  void _togglePinned(BuildContext context, bool pinned) {
    final item = this.item;
    if (item != null) {
      item.model.pinned = pinned;
      if (pinned) {
        item.model.lastOpened = DateTime.now();
      }
      viewModel.pinOrUnpinItem(item.model);
    }
  }

  @override
  Widget build(BuildContext context) => SimpleListItem(
      onTap: () async {
        var item = this.item!;
        if (await Directory(item.model.path).exists()) {
          onOpen?.call(item.model.path);
          return;
        }
        if (await showConfirmationDialog(context,
                content: "The album does not exist, delete it?\n"
                    "Note that maybe you don't want to delete it "
                    "if it is just the containing removable device not plugged in.") ==
            true) {
          _deleteItem(context);
        }
      },
      builder: (hovered) => Flex(direction: Axis.horizontal, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item?.nameForDisplay ?? ""),
                    Text(item?.parentDirectoryForDisplay ?? "loading...",
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.fontSize)),
                  ]),
            ),
            // Expanded(child: ),
            if (hovered)
              GestureDetector(
                  onTap: () => _deleteItem(context),
                  child: const Icon(Icons.clear)),
            if (hovered && !(item?.model.pinned ?? true))
              GestureDetector(
                  onTap: () => _togglePinned(context, true),
                  child: const Icon(Icons.star_border)),
            if (item?.model.pinned ?? false)
              GestureDetector(
                  onTap: () => _togglePinned(context, false),
                  child: const Icon(Icons.star))
          ]));
}
