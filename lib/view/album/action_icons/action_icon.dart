import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../../model/global/batch_action.dart';
import '../../../service/batch_action_service.dart';
import '../../../model/global/model.dart';
import '../../../viewmodel/batch_action_viewmodel.dart';
import '../../../viewmodel/homepage_viewmodel.dart';
import '../../../viewmodel/tag_templates_viewmodel.dart';
import '../../commons/checkbox_row.dart';
import '../../commons/pick_album.dart';
import '../sidetabs/filter_tags_view.dart';

class ActionIcon extends StatelessWidget {
  final bool Function(BatchAction action) onConfirmed;
  final String currentPath;
  const ActionIcon({Key? key, required this.onConfirmed, required this.currentPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.bolt),
      tooltip: "batch action",
      onPressed: () => onBatchActions(context),
    );
  }

  void onBatchActions(BuildContext innerContext) {
    final tagTemplatesViewModel = innerContext.read<TagTemplatesViewModel>();
    showDialog(
        context: innerContext,
        builder: (context) {
          return ChangeNotifierProvider(
            create: (BuildContext context) => BatchActionViewModel(innerContext.read<HomePageViewModel>()),
            child: Consumer<BatchActionViewModel>(builder: (context, viewModel, _) {
              loadSavedState(viewModel);
              return AlertDialog(
                title: const Text("Batch Action"),
                scrollable: true,
                content: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Container(
                        constraints: const BoxConstraints(minWidth: 400),
                        child: _buildDialogContent(context, viewModel, tagTemplatesViewModel))),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (onConfirmed(viewModel.getModel()!)) {
                        Navigator.pop(context, null);
                      }
                    },
                    child: const Text('Apply'),
                  ),
                ],
              );
            }),
          );
        });
  }

  Widget _buildDialogContent(
      BuildContext context, BatchActionViewModel viewModel, TagTemplatesViewModel tagTemplatesViewModel) {
    const subPadding = EdgeInsets.only(left: 24);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      CheckboxRow(
          value: viewModel.enableMoveCopyAction,
          child: const Text("Move or copy to ..."),
          onChanged: (value) => viewModel.enableMoveCopyAction = value!),
      if (viewModel.enableMoveCopyAction)
        Padding(
          padding: subPadding,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildCopyMoveActionContent(context, viewModel)),
        ),
      CheckboxRow(
          value: viewModel.enableTaggingAction,
          child: const Text("Modify tags ..."),
          onChanged: (value) => viewModel.enableTaggingAction = value!),
      if (viewModel.enableTaggingAction)
        Padding(
          padding: subPadding,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildTaggingActionContent(context, viewModel, tagTemplatesViewModel)),
        ),
    ]);
  }

  List<Widget> _buildCopyMoveActionContent(BuildContext context, BatchActionViewModel viewModel) {
    var list = List.generate(
        viewModel.homePageViewModel.getItemsCount(), (index) => viewModel.homePageViewModel.getItem(index));
    final selected = viewModel.path;
    if (selected != null && !list.contains(selected)) {
      list.insert(0, selected);
    }
    return [
      CheckboxRow(value: viewModel.copy, child: const Text("Copy mode"), onChanged: (value) => viewModel.copy = value!),
      const Text("Destination"),
      Row(
        children: [
          Flexible(
            child: DropdownButton<RecentAlbum>(
                value: viewModel.path,
                icon: const Icon(Icons.expand_more),
                hint: const Text("Select ..."),
                isExpanded: true,
                onChanged: (RecentAlbum? value) => viewModel.path = value,
                items: list
                    .map<DropdownMenuItem<RecentAlbum>?>((recent) {
                      final path = recent?.path;
                      if (path == null || path == currentPath) return null;
                      return DropdownMenuItem<RecentAlbum>(value: recent, child: Text(path));
                    })
                    .whereNotNull()
                    .toList()),
          ),
          IconButton(onPressed: () => pickAlbum(context), icon: const Icon(Icons.more_horiz))
        ],
      )
    ];
  }

  List<Widget> _buildTaggingActionContent(
      BuildContext context, BatchActionViewModel viewModel, TagTemplatesViewModel tagTemplatesViewModel) {
    return [
      const Text("Add Tags"),
      ChangeNotifierProvider.value(
        value: tagTemplatesViewModel,
        child: FilterTagsView(
          addTag: (value) => viewModel.addTag(value),
          removeTag: (value) => viewModel.removeTag(value),
          getTagsCount: () => viewModel.getTagsCount(),
          getTagAt: (index) => viewModel.getTagAt(index),
        ),
      ),
      // const Text("Condition type"),
      // DropdownButton<String>(
      //     value: viewModel.conditionType,
      //     icon: const Icon(Icons.expand_more),
      //     isExpanded: true,
      //     onChanged: (String? value) => viewModel.conditionType =
      //         value ?? BatchActionConditionType.defaultValue,
      //     items: BatchActionConditionType.all.keys
      //         .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
      //         .toList()),
      const Text("Remove Tags"),
      ChangeNotifierProvider.value(
        value: tagTemplatesViewModel,
        child: FilterTagsView(
          addTag: (value) => viewModel.addXTag(value),
          removeTag: (value) => viewModel.removeXTag(value),
          getTagsCount: () => viewModel.getXTagsCount(),
          getTagAt: (index) => viewModel.getXTagAt(index),
        ),
      ),
      // const Text("Action type"),
      // DropdownButton<String>(
      //     value: viewModel.actionType,
      //     icon: const Icon(Icons.expand_more),
      //     isExpanded: true,
      //     onChanged: (String? value) => viewModel.actionType =
      //         value ?? BatchActionActionType.defaultValue,
      //     items: BatchActionActionType.all.keys
      //         .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
      //         .toList()),
      const Text("For more complex logics, use the Python SDK instead."),
    ];
  }

  void pickAlbum(BuildContext context) {
    final path = pick_album()?.path;
    if (path != null) {
      context.read<BatchActionViewModel>().setPath(path);
    }
  }

  void loadSavedState(BatchActionViewModel viewModel) async {
    if (viewModel.getModel() != null) return;
    viewModel.setModel(await BatchActionService.instance.getDefault());
  }
}
