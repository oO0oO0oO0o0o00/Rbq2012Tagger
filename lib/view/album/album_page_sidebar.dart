import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'sidetabs/sidetab_tooltip.dart';

/// Side bar on the starting side of the album page
/// containing side tab icons and action buttons.
class AlbumPageSidebar extends StatelessWidget {
  final int selectedIndex;
  final List<Tuple2<String, Widget>> tabIcons;
  final List<Widget> actionIcons;
  final void Function(int index) onSelectSideTab;

  const AlbumPageSidebar({
    Key? key,
    required this.selectedIndex,
    required this.tabIcons,
    required this.actionIcons,
    required this.onSelectSideTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selected = List.filled(tabIcons.length, false);
    final theme = Theme.of(context);
    selected[selectedIndex] = true;
    return Column(children: [
      ToggleButtons(
        renderBorder: false,
        color: Theme.of(context).hintColor,
        selectedBorderColor: Colors.transparent,
        children: tabIcons
            .map((e) => SidetabTooltip(message: e.item1, child: SizedBox(width: 64, height: 64, child: e.item2)))
            .toList(),
        isSelected: selected,
        direction: Axis.vertical,
        onPressed: onSelectSideTab,
      ),
      const Spacer(),
      for (final icon in actionIcons)
        Theme(
          child: icon,
          data: theme.copyWith(iconTheme: theme.iconTheme.copyWith(color: theme.hintColor)),
        )
    ]);
  }
}
