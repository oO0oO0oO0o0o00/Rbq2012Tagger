import 'package:flutter/material.dart';

import '../../model/global/model.dart';
import '../../viewmodel/album/tagged_viewmodel.dart';
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
    return TagView(
        item: TaggedViewModel(item.name, template: item),
        onTap: (_) => onTap(),
        showShortcuts: true);
  }
}
