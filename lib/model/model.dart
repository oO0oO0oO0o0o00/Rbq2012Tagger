import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:synchronized/synchronized.dart';

/// Tag applied to a picture.
///
/// A picture may have 0 to multiple tags
/// and a tag can be applied to arbitrary number of pictures.
/// This is the main and currently the only data
/// that is stored in folder-local databases.
class Tagged {
  static const String tableName = "tagged";
  static const String colName = "name";
  static const String colTag = "tag";

  /// Name of the picture.
  final String name;
  final String tag;

  const Tagged({required this.name, required this.tag});

  Map<String, Object?> toMap() => {colName: name, colTag: tag};
}

/// Album represents a folder that is managed by the app.
/// Pictures are files stored as direct descendent of the folder.
/// Tags applied to pictures are stored in folder-local mysql database.
class Album {
  final String path;

  /// Lock for preventing some unexpected async "concurrent" access.
  ///
  /// If carefully designed there won't be any conflicts
  /// with async access, there's no unpredictable race condition
  /// like in real concurrent cases.
  /// I"m never caerful.
  final Lock instanceLock = Lock();

  /// Folder-local mysql database instance.
  Database? db;

  bool get dbReady => db != null;

  /// Contents of this album, or say list of picture files of the folder.
  List<AlbumItem>? contents;

  Album(this.path);
}

/// Picture stored in the album.
class AlbumItem {
  final String path;

  /// Modified time of this file.
  final DateTime dateTime;

  /// File size in bytes
  final int fileSizeBytes;

  /// Name of the picture file (which is the filename).
  String get name => basename(path);

  AlbumItem(this.path, {required this.dateTime, required this.fileSizeBytes});
}

/// Interface for function signature that is used for sorting the album.
typedef AlbumSorter = Function(List<AlbumItem> items, bool reversed);

/// Available sorting methods.
class AlbumSortModes {
  /// Utility method for creating sorting method using comparator.
  static Function(List<T> items, bool reversed) _createBy<T>(
          int Function(T a, T b) comparator) =>
      (List<T> items, bool reversed) =>
          items.sort((a, b) => comparator(a, b) * (reversed ? -1 : 1));

  /// Utility method for creating sorting method
  /// by comparing a specific attribute.
  static Function(List<T> items, bool reversed) _createByComparing<T>(
          Comparable Function(T item) access) =>
      _createBy((a, b) => access(a).compareTo(access(b)));

  /// Alphabetic sorter.
  static AlbumSorter alphabetic = _createByComparing((item) => item.name);

  /// Method for sorting by last modified date.
  static AlbumSorter byDate = _createByComparing((item) => item.dateTime);
}
