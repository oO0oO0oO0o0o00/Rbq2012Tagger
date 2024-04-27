import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/platform.dart';
import '../../viewmodel/tag_templates_viewmodel.dart';
import '../commons/dialogs.dart';
import 'tag_item_view.dart';

/// Tags management page for managing tag templates.
class TagsMgmtPage extends StatelessWidget {
  final TagTemplatesViewModel tagTemplates;
  final void Function() onClose;

  const TagsMgmtPage({
    Key? key,
    required this.onClose,
    required this.tagTemplates,
  }) : super(key: key);

  static const routeName = '/tags';

  Future<bool> _dealWithPreviousEditingOrCancel(BuildContext context, TagTemplatesViewModel viewModel) async {
    if (viewModel.editingItem == null || viewModel.editingItem?.previous.name == viewModel.editingItem?.current.name) {
      return true;
    }
    final result = await showConfirmationDialog(context,
        content: "You are editing another tag. Save?", hasNeutralButton: true, escAsNeutral: true);
    if (result == null) return false;
    if (result && !await viewModel.commitEditing()) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return isPC()
        ? Material(
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.max, children: [
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
                    iconSize: 36,
                    onPressed: onClose,
                  ),
                ])),
            const SizedBox(height: 48),
            Expanded(child: _buildBody())
          ])))
        : Scaffold(
            appBar: AppBar(
              title: const Text("Managing Tags"),
            ),
            body: _buildBody());
  }

  Widget _buildBody() {
    return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ChangeNotifierProvider.value(
            value: tagTemplates,
            builder: (context, child) => Consumer<TagTemplatesViewModel>(
                builder: (context, viewModel, child) => Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildList(viewModel, context),
                        _buildAddButton(context),
                      ],
                    ))));
  }

  Widget _buildList(TagTemplatesViewModel viewModel, BuildContext context) {
    return Expanded(
        child: ReorderableListView.builder(
      itemBuilder: (context, index) => TagItemView(
          viewModel: viewModel,
          item: viewModel.getItem(index),
          handlePreviousEditing: _dealWithPreviousEditingOrCancel),
      itemCount: viewModel.getItemsCount(),
      onReorder: (old, newIndex) {
        Provider.of<TagTemplatesViewModel>(context, listen: false).move(old, newIndex);
      },
    ));
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
        height: 48,
        child: TextButton(
            onPressed: () async {
              final viewModel = Provider.of<TagTemplatesViewModel>(context, listen: false);
              if (await _dealWithPreviousEditingOrCancel(context, viewModel)) {
                viewModel.beginCreateItemAtTheEnd();
              }
            },
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 12),
              Text("Add"),
            ])));
  }
}
