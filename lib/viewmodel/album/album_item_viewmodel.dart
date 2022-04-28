import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../model/model.dart';
import '../../service/album_service.dart';
import '../common/selectable_list_controller.dart';
import '../tag_templates_viewmodel.dart';
import 'tagged_viewmodel.dart';

/// View model for an [AlbumItem].
class AlbumItemViewModel with ChangeNotifier, Selectable {
  final AlbumItem _model;

  /// Tags applied to the item.
  final List<TaggedViewModel> _tags = [];

  AlbumItemViewModel(this._model);

  String get path => _model.path;

  String get name => _model.name;

  @override
  set selected(value) {
    super.selected = value;
    notifyListeners();
  }

  @override
  set singleSelected(value) {
    super.singleSelected = value;
    notifyListeners();
  }

  int getTagsCount() => _tags.length;

  TaggedViewModel getTagAt(int index) => _tags[index];

  Future<void> updateTags(
      Album album, TagTemplatesViewModel tagTemplates) async {
    final tags = await AlbumService.loadTags(album, _model.name);
    _tags.clear();
    _tags
        .addAll(tags.map((e) => TaggedViewModel(e, tagTemplates.getByName(e))));
    notifyListeners();
  }
}
