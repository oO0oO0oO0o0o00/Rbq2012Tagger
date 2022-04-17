import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:synchronized/synchronized.dart';

class Tagged {
  static const String tableName = "tagged";
  static const String colName = "name";
  static const String colTag = "tag";

  final String name;
  final String tag;

  const Tagged({required this.name, required this.tag});

  Map<String, Object?> toMap() => {colName: name, colTag: tag};
}

class Album {
  final String path;
  final Lock instanceLock = Lock();
  Database? db;
  bool get dbReady => db != null;

  List<AlbumItem>? contents;

  Album(this.path);
}

class AlbumItem {
  final String path;
  final DateTime dateTime;

  String get name => basename(path);

  AlbumItem(this.path, this.dateTime);
}

typedef AlbumSorter = Function(List<AlbumItem> items, bool reversed);

// @sealed
class AlbumSortModes {
  static Function(List<T> items, bool reversed) _createBy<T>(
          int Function(T a, T b) comparator) =>
      (List<T> items, bool reversed) =>
          items.sort((a, b) => comparator(a, b) * (reversed ? -1 : 1));

  static Function(List<T> items, bool reversed) _createByComparing<T>(
          Comparable Function(T item) access) =>
      _createBy((a, b) => access(a).compareTo(access(b)));

  static AlbumSorter alphabetic = _createByComparing((item) => item.name);

  static AlbumSorter byDate = _createByComparing((item) => item.dateTime);
}
