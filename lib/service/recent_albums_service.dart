import '../model/global/model.dart';
import 'global_db_service.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Service for recent albums.
class RecentAlbumsService {
  static Future<void> createTable(Database db, int version) async {
    await db.execute('CREATE TABLE ${RecentAlbum.tableName} ('
        '${RecentAlbum.colPath} TEXT PRIMARY KEY, '
        '${RecentAlbum.colLastOpened} INTEGER, '
        '${RecentAlbum.colPinned} INTEGER) WITHOUT ROWID');
    await db.execute('CREATE INDEX IF NOT EXISTS ${RecentAlbum.colLastOpened} '
        'ON ${RecentAlbum.tableName} (${RecentAlbum.colLastOpened})');
    await db.execute('CREATE INDEX IF NOT EXISTS ${RecentAlbum.colPinned} '
        'ON ${RecentAlbum.tableName} (${RecentAlbum.colPinned})');
  }

  /// Fetch a list of up to `maxCount` recent albums.
  static Future<List<RecentAlbum>> listRecent(int maxCount) async =>
      (await (await GlobalDBService.getDB())
              // Select all pinned items and some recent items
              // so that recent items should not make the amount
              // of selected items to exceed a certain limit.
              .rawQuery(
                  'WITH pinned_items ('
                  '  ${RecentAlbum.colPath}, '
                  '  ${RecentAlbum.colLastOpened}, '
                  '  ${RecentAlbum.colPinned}'
                  ') AS ('
                  '  SELECT * FROM ${RecentAlbum.tableName}'
                  '    WHERE ${RecentAlbum.colPinned} == 1'
                  ') SELECT * FROM ('
                  '  SELECT * FROM ${RecentAlbum.tableName}'
                  '    WHERE ${RecentAlbum.colPinned} == 0'
                  '    ORDER BY'
                  '      ${RecentAlbum.colLastOpened} DESC LIMIT MAX('
                  '        ? - (SELECT COUNT(*) FROM pinned_items), 0'
                  '      )'
                  ') UNION SELECT * FROM pinned_items'
                  '  ORDER BY'
                  '    ${RecentAlbum.colPinned} DESC,'
                  '    ${RecentAlbum.colLastOpened} DESC',
                  [maxCount]))
          .map((e) => RecentAlbum.fromMap(e))
          .toList();

  /// Add or update a recently opened album.
  static Future<void> insert(RecentAlbum item, int? maxCount) async {
    final db = await GlobalDBService.getDB();
    await db.rawInsert(
        'INSERT OR REPLACE INTO ${RecentAlbum.tableName} ('
        '  ${RecentAlbum.colPath},'
        '  ${RecentAlbum.colLastOpened},'
        '  ${RecentAlbum.colPinned}'
        ') VALUES (?, ?, IFNULL(('
        '  SELECT ${RecentAlbum.colPinned} FROM ${RecentAlbum.tableName}'
        '    WHERE ${RecentAlbum.colPath} == ?'
        '), 0))',
        [item.path, item.lastOpenedSerialized, item.path]);
    if (maxCount != null) {
      // Remove some least recent items
      // so that recent items should not make the amount
      // of all items to exceed a certain limit.
      await db.execute(
          'DELETE FROM ${RecentAlbum.tableName}'
          '  WHERE ${RecentAlbum.colPinned} == 0'
          '    AND ${RecentAlbum.colLastOpened} < ('
          '      SELECT MIN(${RecentAlbum.colLastOpened}) FROM ('
          '        WITH lista (${RecentAlbum.colLastOpened}) AS ('
          '          SELECT ${RecentAlbum.colLastOpened}'
          '            FROM ${RecentAlbum.tableName}'
          '            ORDER BY ${RecentAlbum.colLastOpened} DESC LIMIT 1'
          '        ) SELECT * FROM ('
          '          SELECT ${RecentAlbum.colLastOpened}'
          '            FROM ${RecentAlbum.tableName}'
          '              WHERE ${RecentAlbum.colPinned} == 0'
          '          ORDER BY ${RecentAlbum.colLastOpened} DESC LIMIT MAX('
          '            ? - ('
          '              SELECT COUNT(*) FROM ${RecentAlbum.tableName}'
          '                WHERE ${RecentAlbum.colPinned} == 1'
          '            ), 0'
          '          )'
          '        ) UNION SELECT * FROM lista'
          '      )'
          ')',
          [maxCount]);
    }
  }

  static Future<void> remove(RecentAlbum item) async =>
      await (await GlobalDBService.getDB()).delete(RecentAlbum.tableName,
          where: "${RecentAlbum.colPath} == ?", whereArgs: [item.path]);

  /// Pin or unpin album.
  static Future<void> updatePinnedState(RecentAlbum item) async =>
      await (await GlobalDBService.getDB()).update(
          RecentAlbum.tableName, item.toMap(),
          where: "${RecentAlbum.colPath} == ?", whereArgs: [item.path]);
}
