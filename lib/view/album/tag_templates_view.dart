import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/tag_templates_viewmodel.dart';
import 'tag_template_item_view.dart';

class TagTemplatesView extends StatelessWidget {
  const TagTemplatesView({
    Key? key,
    required this.onClickTag,
  }) : super(key: key);

  final Function(String tag) onClickTag;

  @override
  Widget build(BuildContext context) {
    return Consumer<TagTemplatesViewModel>(
      builder: (context, tagTemplatesViewModel, child) => Tags(
        itemCount: tagTemplatesViewModel.getItemsCount(),
        itemBuilder: (int index) {
          final item = tagTemplatesViewModel.getItem(index);
          return TagTemplateItemView(
            item: item,
            onTap: () => onClickTag(item.name),
          );
        },
      ),
    );
  }
}
