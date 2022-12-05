import 'dart:math';

import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';
import '../model/model.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../util/image_util.dart';

/// Service that wraps around file system
/// and database operations on an `Album`.
class AlbumService {
  /// Explicitly defined valid extension names for pictures.

  /// Version of database schema.
  static const _schemaVersion = 1;
  static final rng = Random();

  static Album getAlbum(String path) => Album(path);

  static Future<Database> getDatabase(Album album) async {
    sqfliteFfiInit();
    late Database db;
    await initSavDir(album);
    await album.instanceLock
        .synchronized(() async => db = album.db ??= await databaseFactoryFfi.openDatabase(_getDbPath(album),
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

  static Future<void> closeDatabase(Album album) async => await album.instanceLock.synchronized(() async {
        await album.db?.close();
        album.db = null;
      });

  static Future<void> loadContents(Album album) async {
    album.contents ??= await Directory(album.path)
        .list()
        .asyncMap((entity) async {
          var stat = await entity.stat();
          return (entity is File && isImageExtension(entity.path))
              ? AlbumItem(entity.path, dateTime: stat.modified, fileSizeBytes: stat.size)
              : null;
        })
        .where((album) => album != null)
        .map((album) => album!)
        .toList();
  }

  static Future<Tuple2<AlbumItem, Tuple2<File, File>?>> preflightImportFromAlbumItem(
          Album album, AlbumItem item) async =>
      preflightImportFromFile(album, name: item.name, fromPath: item.path);

  /// Returns created album item and the conflicted file (if any).
  static Future<Tuple2<AlbumItem, Tuple2<File, File>?>> preflightImportFromFile(Album album,
      {required String name, required String fromPath}) async {
    final srcFile = File(fromPath);
    final stat = await srcFile.stat();
    final dst = path.join(album.path, name);
    final dstFile = File(dst);
    return Tuple2(AlbumItem(dst, dateTime: stat.modified, fileSizeBytes: stat.size),
        await dstFile.exists() ? Tuple2(srcFile, dstFile) : null);
  }

  static Future<void> importPictureFromAlbumItem(
          {required AlbumItem dest, required AlbumItem src, required bool copy}) async =>
      importPictureFromFile(dest, fromPath: src.path, copy: copy);

  static Future<void> importPictureFromFile(AlbumItem dest, {required String fromPath, required bool copy}) async {
    final dstFile = File(dest.path);
    final src = File(fromPath);
    assert(await src.exists());
    final resultingPath = await (copy ? src.copy : src.rename)(dstFile.path);
    assert(resultingPath.path == dstFile.path);
  }

  static Future<AlbumItem> useNextAvailableName(AlbumItem item) async {
    if (!await File(item.path).exists()) return item;
    final folder = path.dirname(item.path);
    final basename = path.basenameWithoutExtension(item.name) + DateFormat("-yyMMdd-hhmmss").format(DateTime.now());
    final extension = path.extension(item.name);
    var file = File(path.join(folder, basename + extension));
    const randomDigits = 6;
    final rngBound = pow(10, randomDigits).toInt();
    while (await file.exists()) {
      final name = basename + rng.nextInt(rngBound).toString().padLeft(randomDigits, "0") + extension;
      file = File(path.join(folder, name));
    }
    return AlbumItem(file.path, dateTime: item.dateTime, fileSizeBytes: item.fileSizeBytes);
  }

  static Future<void> removeItemtags(Album album, AlbumItem item) async {
    (await getDatabase(album)).delete(Tagged.tableName, where: "${Tagged.colName} == ?", whereArgs: [item.name]);
  }

  static Future<Iterable<String>> loadTags(Album album, String pictureName) async => (await (await getDatabase(album))
          .query(Tagged.tableName, where: '${Tagged.colName} == ?', whereArgs: [pictureName], orderBy: Tagged.colTag))
      .map((e) => e[Tagged.colTag] as String);

  static Future<bool> addTag(Album album, Tagged tagged) async =>
      (await (await getDatabase(album))
          .insert(Tagged.tableName, tagged.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore)) ==
      1;

  static Future<bool> removeTag(Album album, Tagged tagged) async =>
      (await (await getDatabase(album)).delete(Tagged.tableName,
          where: "${Tagged.colName} == ? and ${Tagged.colTag} == ?", whereArgs: [tagged.name, tagged.tag])) ==
      1;

  static Future<bool> isManaged(Album album) async => await Directory(_getSavDir(album)).exists();

  static Future<void> initSavDir(Album album) async => await Directory(_getSavDir(album)).create();

  static String _getSavDir(Album album) => path.join(album.path, ".rbq2012.tagger");

  static String _getDbPath(Album album) => path.join(_getSavDir(album), "album.db");

  /// Load the intersection or union of sets of tags given pictures.
  static Future<Iterable<String>> loadTagsForPictures(Album album, List<String> pictures,
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
