import '../../model/model.dart';
import '../../service/album_service.dart';
import 'album_item_viewmodel.dart';
import 'tag_templates_viewmodel.dart';

/// A strut that encapsulates fields that are extensively
/// used in both [AlbumController] and [AlbumViewModel].
class AlbumCoreStruct {
  final Album model;

  List<AlbumItemViewModel?>? cache;

  final tagTemplates = TagTemplatesViewModel();

  AlbumCoreStruct(String path) : model = AlbumService.getAlbum(path);
}
