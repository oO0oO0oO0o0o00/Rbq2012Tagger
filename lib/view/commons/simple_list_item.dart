import 'package:flutter/material.dart';

/// A simple list item view with hover effect.
class SimpleListItem extends StatefulWidget {
  final Function() onTap;
  final Function(bool hovered)? onHover;
  final Widget Function(bool hovered) builder;

  SimpleListItem(
      {Key? key, Function()? onTap, this.onHover, required this.builder})
      : onTap = (onTap ?? (() {})),
        super(key: key);

  @override
  State<SimpleListItem> createState() => _SimpleListItemState();
}

class _SimpleListItemState extends State<SimpleListItem> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: widget.onTap,
        onHover: (value) {
          setState(() => hovered = value);
          widget.onHover?.call(hovered);
        },
        mouseCursor: SystemMouseCursors.basic,
        // onExit: (value) => setState(() => isHover = false),
        child: Container(
          child: widget.builder(hovered),
          constraints: BoxConstraints(
              minHeight: (Theme.of(context).iconTheme.size ?? 24) + 16),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
              border: Border.all(
                  color: hovered
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent)),
        ));
  }
}
