import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../util/text_editing_controller.dart';

import '../../../model/global/search_options.dart';
import '../../../service/search_options_service.dart';
import '../../../viewmodel/album/search_options_viewmodel.dart';
import '../../commons/date_text_field.dart';
import 'filter_tags_view.dart';

class SearchView extends StatefulWidget {
  final void Function(SearchOptions? filter) onSetFilter;

  const SearchView({Key? key, required this.onSetFilter}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  static const double rowSpacing = 16;
  late final SearchOptionsViewModel viewModel;
  late TextEditingController nameController;
  late TextEditingController sizeFromController;
  late TextEditingController sizeToController;

  @override
  void initState() {
    super.initState();
    viewModel = SearchOptionsViewModel();
    loadSavedState();
    nameController = TextEditingController()
      ..addListener(() {
        viewModel.byName = nameController.text;
      });
    sizeFromController = TextEditingController()
      ..addListener(() {
        viewModel.fromSizeKb = sizeFromController.text;
      });
    sizeToController = TextEditingController()
      ..addListener(() {
        viewModel.toSizeKb = sizeToController.text;
      });
    viewModel.addListener(() {
      nameController.setTextIfDifferent(viewModel.byName);
      sizeFromController.setTextIfDifferent(viewModel.fromSizeKb);
      sizeToController.setTextIfDifferent(viewModel.toSizeKb);
    });
  }

  void loadSavedState() async {
    viewModel.setModel(await SearchOptionsService.instance.getDefault());
  }

  @override
  void dispose() {
    nameController.dispose();
    sizeFromController.dispose();
    sizeToController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: Consumer<SearchOptionsViewModel>(
          builder: (context, viewModel, child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name pattern", hintText: "keyword or wildcard"),
                ),
                const SizedBox(height: rowSpacing),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: sizeFromController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "Size from"))),
                    const Text("   -   "),
                    Expanded(
                        child: TextField(
                            controller: sizeToController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: "to"))),
                    const Text("KB")
                  ],
                ),
                const SizedBox(height: rowSpacing),
                Row(children: [
                  DateTextField(
                      labelText: "From date",
                      eventSource: viewModel,
                      uplink: (dateTime) => viewModel.fromTime = dateTime,
                      downlink: () => viewModel.fromTime),
                  const SizedBox(width: rowSpacing),
                  DateTextField(
                      labelText: "to date",
                      eventSource: viewModel,
                      uplink: (dateTime) => viewModel.toTime = dateTime,
                      downlink: () => viewModel.toTime)
                ]),
                const SizedBox(height: rowSpacing),
                Text("Included tags", style: TextStyle(color: Theme.of(context).hintColor)),
                FilterTagsView(
                  addTag: viewModel.addTag,
                  removeTag: viewModel.removeTag,
                  getTagsCount: viewModel.getTagsCount,
                  getTagAt: viewModel.getTagAt,
                ),
                const SizedBox(height: rowSpacing),
                Text("Excluded tags", style: TextStyle(color: Theme.of(context).hintColor)),
                FilterTagsView(
                  addTag: viewModel.addXTag,
                  removeTag: viewModel.removeXTag,
                  getTagsCount: viewModel.getXTagsCount,
                  getTagAt: viewModel.getXTagAt,
                ),
                const SizedBox(height: rowSpacing),
                const Text("Condition type"),
                DropdownButton<String>(
                    value: viewModel.conditionType,
                    icon: const Icon(Icons.expand_more),
                    isExpanded: true,
                    onChanged: (String? value) =>
                        viewModel.conditionType = value ?? SearchOptionsConditionType.defaultValue,
                    items: SearchOptionsConditionType.all.keys
                        .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                        .toList()),
                const SizedBox(height: rowSpacing),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.background),
                    child: const Text("Clear"),
                    onPressed: () => widget.onSetFilter(null),
                  ),
                  const SizedBox(width: rowSpacing),
                  ElevatedButton(
                    child: const Text("Filter"),
                    onPressed: () => widget.onSetFilter(viewModel.getModel()!),
                  )
                ]),
              ],
            ),
          ),
        ),
      );
}
