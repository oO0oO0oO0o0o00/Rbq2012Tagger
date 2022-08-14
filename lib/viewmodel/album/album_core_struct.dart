import '../../model/model.dart';
import '../../service/album_service.dart';
import '../tag_templates_viewmodel.dart';
import 'album_item_viewmodel.dart';

/// A strut that encapsulates fields that are extensively
/// used in both [AlbumController] and [AlbumViewModel].
class AlbumCoreStruct {
  final Album model;

  List<AlbumItem>? _filteredContents;

  List<AlbumItem>? get filteredContents => _filteredContents ?? model.contents;

  set filteredContents(List<AlbumItem>? value) => _filteredContents = value;

  List<AlbumItemViewModel?>? cache;

  final TagTemplatesViewModel tagTemplates;

  AlbumCoreStruct(String path, {required this.tagTemplates})
      : model = AlbumService.getAlbum(path);
}
