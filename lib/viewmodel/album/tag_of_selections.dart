import 'dart:async';

import '../../model/model.dart';
import '../../service/album_service.dart';
import '../tag_templates_viewmodel.dart';
import 'tagged_viewmodel.dart';

/// Wrapper around the ability of showing intersection or union of
/// set of tags of selected items.
class TagsOfSelections {
  List<TaggedViewModel>? _intersection;
  List<TaggedViewModel>? _union;

  bool _invalid = false;

  List<TaggedViewModel>? get intersection => _intersection;
  List<TaggedViewModel>? get union => _union;
  bool get invalid => _invalid;

  void invalidate() => _invalid = true;

  Future<void> loadTags(Album album,
      TagTemplatesViewModel tagTemplatesViewModel, List<String> selection,
      {required bool intersectionMode}) async {
    final list = (await AlbumService.loadTagsForPictures(album, selection,
            intersectionMode: intersectionMode))
        .map((e) => TaggedViewModel(e, tagTemplatesViewModel.getByName(e)))
        .toList();
    if (intersectionMode) {
      _intersection = list;
    } else {
      _union = list;
    }
    _invalid = false;
  }
}
