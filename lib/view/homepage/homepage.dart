import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:tagger/util/platform.dart';
import 'package:provider/provider.dart';

import '../commons/dialogs.dart';
import '../../viewmodel/homepage_viewmodel.dart';
import '../../viewmodel/recent_album_view_model.dart';
import '../commons/simple_list_item.dart';

class MyHomePage extends StatelessWidget {
  static const title = "MeowCat's Pictures Tagging Tool";

  static const routeName = '/';

  final HomePageViewModel viewModel;
  final void Function(String path) onOpen;

  const MyHomePage({Key? key, required this.onOpen, required this.viewModel})
      : super(key: key);

  void _selectAndOpen(BuildContext context) {
    final file = DirectoryPicker()
      ..defaultFilterIndex = 0
      ..title = 'Select a document';

    final result = file.getDirectory();
    if (result != null) {
      _open(context, result.path);
    }
  }

  void _open(BuildContext context, String path) {
    onOpen(path);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: viewModel,
        builder: (context, child) =>
            isPC() ? _buildForPC(context) : _buildForMobile(context));
  }

  Widget _buildForMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              Row(children: [
                const Expanded(child: SizedBox()),
                Expanded(
                    flex: _HomePageLayoutMode.get(constraints)
                        .mainViewExpandedFactor,
                    child: _buildBodyForPC(context)),
                Expanded(
                    child: const SizedBox(),
                    flex: _HomePageLayoutMode.get(constraints)
                        .auxViewExpandedFactor),
              ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectAndOpen(context),
        tooltip: 'Open',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildForPC(BuildContext context) {
    return Material(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(title, style: Theme.of(context).textTheme.headline2),
      const SizedBox(height: 48),
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            Row(children: [
          const Expanded(child: SizedBox()),
          Expanded(
              flex: _HomePageLayoutMode.get(constraints).mainViewExpandedFactor,
              child: _buildBodyForPC(context)),
          Expanded(
              child: const SizedBox(),
              flex: _HomePageLayoutMode.get(constraints).auxViewExpandedFactor),
        ]),
      )
    ]));
  }

  Widget _buildBodyForPC(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
                onPressed: () => _selectAndOpen(context),
                child: const Text("Open Folder..."))),
        const SizedBox(height: 24),
        Text('Recent', style: Theme.of(context).textTheme.headline4),
        const SizedBox(height: 12),
        Consumer<HomePageViewModel>(
            builder: (consumerContext, viewModel, child) =>
                _buildCentralView(viewModel)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: () => _selectAndOpen(context),
                child: const Text("Manage Tags..."))
          ],
        )
      ],
    );
  }

  ListView _buildCentralView(HomePageViewModel viewModel) {
    return ListView.builder(
        itemBuilder: (context, index) {
          var recentAlbum = viewModel.getItem(index);
          return RecentItemView(
              viewModel: viewModel,
              item: recentAlbum == null
                  ? null
                  : RecentAlbumViewModel(recentAlbum),
              onOpen: _open);
        },
        shrinkWrap: true,
        itemCount: viewModel.getItemsCount());
  }
}

typedef OpenAlbumFunction = Function(BuildContext context, String path);

class RecentItemView extends StatelessWidget {
  const RecentItemView({
    Key? key,
    required this.viewModel,
    required this.item,
    this.onOpen,
  }) : super(key: key);

  final HomePageViewModel viewModel;
  final RecentAlbumViewModel? item;
  final OpenAlbumFunction? onOpen;

  void _deleteItem(BuildContext context) {
    if (item != null) {
      viewModel.removeItem(item!.model);
    }
  }

  void _togglePinned(BuildContext context, bool pinned) {
    final item = this.item;
    if (item != null) {
      item.model.pinned = pinned;
      if (pinned) {
        item.model.lastOpened = DateTime.now();
      }
      viewModel.pinOrUnpinItem(item.model);
    }
  }

  @override
  Widget build(BuildContext context) => SimpleListItem(
      onTap: () async {
        var item = this.item!;
        if (await Directory(item.model.path).exists()) {
          onOpen?.call(context, item.model.path);
          return;
        }
        if (await showConfirmationDialog(context,
                content: "The album does not exist, delete it?\n"
                    "Note that maybe you don't want to delete it "
                    "if it is just the containing removable device not plugged in.") ==
            true) {
          _deleteItem(context);
        }
      },
      builder: (hovered) => Flex(direction: Axis.horizontal, children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item?.nameForDisplay ?? ""),
                    Text(item?.parentDirectoryForDisplay ?? "loading...",
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.fontSize)),
                  ]),
            ),
            // Expanded(child: ),
            if (hovered)
              GestureDetector(
                  onTap: () => _deleteItem(context),
                  child: const Icon(Icons.clear)),
            if (hovered && !(item?.model.pinned ?? true))
              GestureDetector(
                  onTap: () => _togglePinned(context, true),
                  child: const Icon(Icons.star_border)),
            if (item?.model.pinned ?? false)
              GestureDetector(
                  onTap: () => _togglePinned(context, false),
                  child: const Icon(Icons.star))
          ]));
}

class _HomePageLayoutMode {
  static _HomePageLayoutMode? _small;
  static _HomePageLayoutMode? _medium;
  static _HomePageLayoutMode? _large;

  final int mainViewExpandedFactor;
  final int auxViewExpandedFactor;

  _HomePageLayoutMode._(
      this.mainViewExpandedFactor, this.auxViewExpandedFactor);

  factory _HomePageLayoutMode.get(BoxConstraints constraints) {
    if (constraints.maxWidth > 1200) {
      return _large ??= _HomePageLayoutMode._(2, 3);
    }
    if (constraints.maxWidth > 800) {
      return _medium ??= _HomePageLayoutMode._(2, 2);
    }
    return _small ??= _HomePageLayoutMode._(4, 1);
  }
}
