import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../../../../viewmodel/album/tagged_viewmodel.dart';
import '../../../../viewmodel/tag_templates_viewmodel.dart';
import '../../commons/tag_view.dart';

class FilterTagsView extends StatelessWidget {
  const FilterTagsView({
    Key? key,
    required this.addTag,
    required this.removeTag,
    required this.getTagsCount,
    required this.getTagAt,
  }) : super(key: key);

  final void Function(String tag) addTag;
  final void Function(String tag) removeTag;
  final int Function() getTagsCount;
  final String Function(int index) getTagAt;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // print(context.read<TagTemplatesViewModel>());
    return Container(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.background),
            color: theme.hoverColor),
        child: Column(children: [
          Container(
            constraints:
                const BoxConstraints(minHeight: 20, minWidth: double.infinity),
            child: Tags(
              itemCount: getTagsCount(),
              itemBuilder: (index) {
                final tag = getTagAt(index);
                return TagView(
                    item: TaggedViewModel(tag,
                        template: context
                            .read<TagTemplatesViewModel>()
                            .getByName(tag)),
                    onClose: (tag) => removeTag(tag));
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  splashRadius: 24,
                  iconSize: 24,
                  color: theme.hintColor,
                  onPressed: () => showTemplates(context, theme),
                  icon: const Icon(
                    Icons.add,
                  )),
            ],
          )
        ]));
  }

  void showTemplates(BuildContext context, ThemeData theme) {
    showPopover(
        context: context,
        transitionDuration: const Duration(milliseconds: 150),
        bodyBuilder: (bodyContext) => ChangeNotifierProvider.value(
            value: context.read<TagTemplatesViewModel>(),
            child:
                // TagTemplatesView(onClickTag: (tag) => addTag(tag))
                Consumer<TagTemplatesViewModel>(
              builder: (context, value, child) => Tags(
                itemCount: value.getItemsCount(),
                itemBuilder: (index) {
                  final tag = value.getItem(index);
                  return TagView(
                      item: TaggedViewModel(tag.name, template: tag),
                      onTap: addTag);
                },
              ),
            )),
        direction: PopoverDirection.right,
        barrierColor: Colors.transparent,
        backgroundColor: theme.colorScheme.primary.withAlpha(150),
        arrowHeight: 24,
        arrowWidth: 48,
        constraints: const BoxConstraints(minHeight: 100, minWidth: 200));
  }
}
