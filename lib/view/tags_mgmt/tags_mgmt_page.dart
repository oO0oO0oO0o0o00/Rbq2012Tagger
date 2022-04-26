import 'package:flutter/material.dart';
import '../commons/dialogs.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/tag_templates_viewmodel.dart';
import 'tag_item_view.dart';

/// Tags management page for managing tag templates.
class TagsMgmtPage extends StatelessWidget {
  const TagsMgmtPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/tags';

  Future<bool> _dealWithPreviousEditingOrCancel(
      BuildContext context, TagTemplatesViewModel viewModel) async {
    if (viewModel.editingItem == null ||
        viewModel.editingItem?.previous.name ==
            viewModel.editingItem?.current.name) {
      return true;
    }
    final result = await showConfirmationDialog(context,
        content: "You are editing another tag. Save?",
        hasNeutralButton: true,
        escAsNeutral: true);
    if (result == null) return false;
    if (result && !await viewModel.commitEditing()) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Managing Tags"),
        ),
        body: Center(
            child: SizedBox(
                width: 400,
                child: ChangeNotifierProvider(
                    create: (context) => TagTemplatesViewModel(),
                    builder: (context, child) => _buildBody()))));
  }

  Widget _buildBody() {
    return Consumer<TagTemplatesViewModel>(
        builder: (context, viewModel, child) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildList(viewModel, context),
                  _buildAddButton(context)
                ]));
  }

  Widget _buildList(TagTemplatesViewModel viewModel, BuildContext context) {
    return ReorderableListView.builder(
      itemBuilder: (context, index) => TagItemView(
          viewModel: viewModel,
          item: viewModel.getItem(index),
          handlePreviousEditing: _dealWithPreviousEditingOrCancel),
      itemCount: viewModel.getItemsCount(),
      onReorder: (old, newIndex) {
        Provider.of<TagTemplatesViewModel>(context, listen: false)
            .move(old, newIndex);
      },
      shrinkWrap: true,
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
        height: 48,
        child: TextButton(
            onPressed: () async {
              final viewModel =
                  Provider.of<TagTemplatesViewModel>(context, listen: false);
              if (await _dealWithPreviousEditingOrCancel(context, viewModel)) {
                viewModel.beginCreateItemAtTheEnd();
              }
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 12),
                  Text("Add")
                ])));
  }
}
