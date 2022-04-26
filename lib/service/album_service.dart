import '../model/model.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Service that wraps around file system
/// and database operations on an `Album`.
class AlbumService {
  /// Explicitly defined valid extension names for pictures.
  static const _pictureExtensions = [".png", ".jpg"];

  /// Version of database schema.
  static const _schemaVersion = 1;

  static Album getAlbum(String path) => Album(path);

  static Future<Database> getDatabase(Album album) async {
    sqfliteFfiInit();
    late Database db;
    await album.instanceLock.synchronized(() async => db =
        album.db ??= await databaseFactoryFfi.openDatabase(_getDbPath(album),
            options: OpenDatabaseOptions(
                version: _schemaVersion,
                onCreate: (db, version) async {
                  await db.execute('CREATE TABLE ${Tagged.tableName} ('
                      '${Tagged.colName} TEXT, '
                      '${Tagged.colTag} TEXT, '
                      'PRIMARY KEY (${Tagged.colName}, ${Tagged.colTag}))');
                })));
    return db;
  }

  static Future<void> closeDatabase(Album album) async =>
      await album.instanceLock.synchronized(() async {
        await album.db?.close();
        album.db = null;
      });

  static Future<void> loadContents(Album album) async {
    album.contents ??= await Directory(album.path)
        .list()
        .asyncMap((entity) async => (entity is File &&
                _pictureExtensions.contains(extension(entity.path)))
            ? AlbumItem(entity.path, (await entity.stat()).modified)
            : null)
        .where((album) => album != null)
        .map((album) => album!)
        .toList();
  }

  static Future<Iterable<String>> loadTags(
          Album album, String pictureName) async =>
      (await (await getDatabase(album)).query(Tagged.tableName,
              where: 'name == ?',
              whereArgs: [pictureName],
              orderBy: Tagged.colTag))
          .map((e) => e[Tagged.colTag] as String);

  static Future<bool> addTag(Album album, Tagged tagged) async =>
      (await (await getDatabase(album)).insert(Tagged.tableName, tagged.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore)) ==
      1;

  static Future<bool> removeTag(Album album, Tagged tagged) async =>
      (await (await getDatabase(album)).delete(Tagged.tableName,
          where: "${Tagged.colName} == ? and ${Tagged.colTag} == ?",
          whereArgs: [tagged.name, tagged.tag])) ==
      1;

  static Future<bool> isManaged(Album album) async =>
      File(_getDbPath(album)).exists();

  static Future<void> initDatabase(Album album) async =>
      await getDatabase(album);

  static String _getDbPath(Album album) =>
      join(album.path, "rbq2012.album.tags.db");

  /// Load the intersection or union of sets of tags given pictures.
  static Future<Iterable<String>> loadTagsForPictures(
      Album album, List<String> pictures,
      {required bool intersectionMode}) async {
    final op = intersectionMode ? "INTERSECT" : "UNION";
    return (await (await getDatabase(album)).rawQuery(
            [
              for (final _ in pictures)
                "SELECT ${Tagged.colTag} FROM ${Tagged.tableName} "
                    "WHERE ${Tagged.colName} == ?"
            ].join(" $op "),
            pictures))
        .map((e) => e[Tagged.colTag] as String);
  }
}
