import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/album/album_items_sort_mode_viewmodel.dart';
import '../../../viewmodel/album/album_viewmodel.dart';
import '../sidetabs/sidetab_tooltip.dart';

/// The "sort by" icon.
class SortIcon extends StatelessWidget {
  final Offset? offset;

  const SortIcon({
    Key? key,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SidetabTooltip(
      message: "sort by",
      child: TooltipVisibility(
        visible: false,
        child: PopupMenuButton(
            offset: offset ?? Offset.zero,
            icon: const Icon(Icons.sort),
            tooltip: "",
            onSelected: (AlbumItemsSortModeViewModel item) {
              Provider.of<AlbumViewModel>(context, listen: false).sortMode = item;
            },
            itemBuilder: (innerContext) => AlbumItemsSortModeViewModel.sortModes
                .map((e) => PopupMenuItem(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                    value: e,
                    child: Row(children: [
                      Icon(e.icon, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(e.name),
                      if (e == Provider.of<AlbumViewModel>(context, listen: false).sortMode) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.check, color: Colors.black),
                      ]
                    ])))
                .toList()),
      ),
    );
  }
}
