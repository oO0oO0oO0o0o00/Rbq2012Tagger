import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/platform.dart';
import '../../viewmodel/homepage_viewmodel.dart';
import '../../viewmodel/recent_album_view_model.dart';
import '../commons/pick_album.dart';
import 'recent_item_view.dart';

/// Home page. It was called "MyHomePage" and it's still called so.
class MyHomePage extends StatelessWidget {
  static const title = "Baka MeowCat's Pictures Tagging Tool";

  static const routeName = '/';

  final HomePageViewModel viewModel;

  final void Function(String path) onOpen;

  final void Function() onOpenTagsMgmt;

  const MyHomePage(
      {Key? key,
      required this.onOpen,
      required this.onOpenTagsMgmt,
      required this.viewModel})
      : super(key: key);

  void _selectAndOpen(BuildContext context) {
    final result = pick_album();
    if (result != null) {
      onOpen(result.path);
    }
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
      Text(title, style: Theme.of(context).textTheme.displayMedium),
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
        Text('Recent', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Consumer<HomePageViewModel>(
            builder: (consumerContext, viewModel, child) =>
                _buildCentralView(viewModel)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
                onPressed: onOpenTagsMgmt, child: const Text("Manage Tags..."))
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
              onOpen: onOpen);
        },
        shrinkWrap: true,
        itemCount: viewModel.getItemsCount());
  }
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
