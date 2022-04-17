import 'package:flutter/material.dart';

import '../../model/global/model.dart';
import '../commons/tag_view.dart';

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
              const Icon(Icons.keyboard),
              const SizedBox(width: 4),
              Text(item.shortcut!, style: textStyle)
            ]
          ],
        ));
  }
}
