import 'package:flutter/material.dart';

import '../../viewmodel/album/tagged_viewmodel.dart';

/// A tag-like view.
class TagView extends StatelessWidget {
  const TagView({
    Key? key,
    required this.item,
    this.onTap,
    this.onClose,
    this.showShortcuts = false,
  }) : super(key: key);
  final TaggedViewModel item;
  final void Function(String tag)? onTap;
  final void Function(String tag)? onClose;
  final bool showShortcuts;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(10);
    final backgroundColor = item.template?.color.background ?? Colors.grey;
    return Material(
        borderRadius: BorderRadius.circular(18),
        color: backgroundColor,
        elevation: 4,
        child: InkWell(
            onTap: () => onTap?.call(item.tag),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    item.tag,
                    style: TextStyle(color: item.template?.color.foreground),
                  ),
                  if (showShortcuts && item.template?.shortcut != null)
                    ...buildShortcutView(),
                  if (onClose != null) ...[
                    const SizedBox(width: 8),
                    Material(
                        color: Colors.transparent,
                        child: InkWell(
                            borderRadius: border,
                            onTap: () => onClose?.call(item.tag),
                            child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: item.template?.color.foreground,
                                ))))
                  ]
                ]))));
  }

  List<Widget> buildShortcutView() {
    final template = item.template!;
    final color = template.color.foreground;
    return [
      const SizedBox(width: 8),
      Icon(Icons.keyboard, color: color, size: 16),
      const SizedBox(width: 4),
      Text(template.shortcut!, style: TextStyle(color: color))
    ];
  }
}
