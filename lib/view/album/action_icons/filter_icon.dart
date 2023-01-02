import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodel/album/album_viewmodel.dart';
import '../sidetabs/sidetab_tooltip.dart';

class FilterIcon extends StatelessWidget {
  final Offset? offset;
  const FilterIcon({
    Key? key,
    this.offset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SidetabTooltip(
        message: "filtering...",
        child: TooltipVisibility(
            visible: false,
            child: PopupMenuButton(
                offset: offset ?? Offset.zero,
                icon: const Icon(Icons.filter_list_alt),
                tooltip: "Filtering...",
                onSelected: (item) {
                  Provider.of<AlbumViewModel>(context, listen: false).filter = null;
                },
                itemBuilder: (innerContext) => [
                      const PopupMenuItem(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 28),
                          value: "傻逼不能 null",
                          child: Text("clear filter"))
                    ])));
    // Row(children: [
    //   Icon(e.icon, color: Colors.black),)
  }
}
