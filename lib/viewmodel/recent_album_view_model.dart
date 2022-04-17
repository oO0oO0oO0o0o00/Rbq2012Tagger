import 'dart:io';
import 'package:path/path.dart' as path;
import '../model/global/model.dart';

class RecentAlbumViewModel {
  final RecentAlbum model;

  RecentAlbumViewModel(this.model);

  String get parentDirectoryForDisplay =>
      File(model.path)
          .parent
          .path
          .replaceAll(RegExp("[/\\\\]"), "▸")
          .replaceAllMapped(
              RegExp("^([A-Z]):"), (match) => "🖴 ${match.group(1)}") +
      "▸";

  String get nameForDisplay => path.basename(model.path);
}
