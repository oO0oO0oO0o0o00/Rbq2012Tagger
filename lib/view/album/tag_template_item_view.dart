import 'package:flutter/material.dart';

import '../../model/global/model.dart';
import '../commons/tag_view.dart';

/// View of a tag template.
///
/// Has:
///  * Tag-like looking
///  * name and color specification
///  * shortcut note
/// See also: [AlbumItemTagView]
class TagTemplateItemView extends StatelessWidget {
  const TagTemplateItemView({Key? key, required this.item, required this.onTap})
      : super(key: key);

  final TagTemplate item;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: item.color.foreground);
    return TagView(
        backgroundColor: item.color.background,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          key: Key(item.name),
          children: [
            Text(item.name, style: textStyle),
            if (item.shortcut != null) ...[
              const SizedBox(width: 12),
              Icon(Icons.keyboard, color: item.color.foreground),
              const SizedBox(width: 4),
              Text(item.shortcut!, style: textStyle)
            ]
          ],
        ));
  }
}
