import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/album/album_viewmodel.dart';
import 'album_item_tag_view.dart';
import 'scalable_card_view.dart';

class BulkTagsView extends StatefulWidget {
  const BulkTagsView({
    Key? key,
    required this.onClickTag,
  }) : super(key: key);

  final Function(String tag) onClickTag;

  @override
  State<BulkTagsView> createState() => _BulkTagsViewState();
}

class _BulkTagsViewState extends State<BulkTagsView>
    with AutomaticKeepAliveClientMixin {
  final isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AlbumViewModel>(builder: (context, albumViewModel, child) {
      final theme = Theme.of(context);
      final selections = albumViewModel.selectionController.selections;
      return ScalableCardView(
        builder: (constraint) => selections.isEmpty
            ? const [Text("(no pictures selected)")]
            : selections.length > 121
                ? const [
                    Text("(too many selected, use Filter & Actions instead)")
                  ]
                : _buildBody(theme, constraint, albumViewModel),
      );
    });
  }

  List<Widget> _buildBody(ThemeData theme, BoxConstraints constraint,
      AlbumViewModel albumViewModel) {
    return [
      Text("Tags of Selections", style: theme.textTheme.titleLarge),
      ToggleButtons(
        borderColor: theme.toggleableActiveColor,
        color: theme.toggleableActiveColor,
        selectedBorderColor: theme.toggleableActiveColor,
        splashColor: theme.splashColor,
        constraints: const BoxConstraints(minWidth: 84, minHeight: 28),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        fillColor: theme.toggleableActiveColor,
        selectedColor: theme.dialogBackgroundColor,
        children: const [
          Text("Intersection"),
          Text("Union"),
        ],
        onPressed: (int index) {
          setState(() {
            isSelected[index] = true;
            isSelected[1 - index] = false;
          });
        },
        isSelected: isSelected,
      ),
      ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraint.maxHeight / 2),
        child: Tags(
          itemCount: albumViewModel.getTagsOfSelectedItemsCount(isSelected[0]),
          itemBuilder: (int index) {
            final item =
                albumViewModel.getTagOfSelectedItemsAt(index, isSelected[0]);
            return AlbumItemTagView(
                item: item,
                onClose: (String tag) =>
                    albumViewModel.removeTagFromSelected(tag));
          },
        ),
      )
    ];
  }

  @override
  bool get wantKeepAlive => true;
}
