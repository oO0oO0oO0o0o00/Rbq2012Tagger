import '../model/global/model.dart';
import 'global_db_service.dart';
import 'package:sqflite_common/sqlite_api.dart';

class SearchOptionsService {
  static Future<void> createTable(Database db, int version) async {
    await db.execute('CREATE TABLE ${SearchOptions.tableName} ('
        '${SearchOptions.colName} TEXT PRIMARY KEY, '
        '${SearchOptions.colByName} TEXT,'
        '${SearchOptions.colByNameCase} INT,'
        '${SearchOptions.colFromTime} INT,'
        '${SearchOptions.colToTime} INT,'
        '${SearchOptions.colFromSizeKb} INT,'
        '${SearchOptions.colToSizeKb} INT,'
        '${SearchOptions.colTags} TEXT,'
        '${SearchOptions.colXtags} TEXT) WITHOUT ROWID');
  }

  static Future<SearchOptions> getDefault() async {
    return await get("") ?? SearchOptions(name: "");
  }

  static Future<SearchOptions?> get(String name) async {
    // await (await GlobalDBService.getDB())
    //     .execute('drop table ${SearchOptions.tableName}');
    // await createTable(await GlobalDBService.getDB(), 2);
    var list = await (await GlobalDBService.getDB()).query(
        SearchOptions.tableName,
        distinct: true,
        where: "name == ?",
        whereArgs: [name]);
    return list.isEmpty ? null : SearchOptions.fromMap((list).first);
  }

  static Future<void> save(SearchOptions searchOptions) async =>
      await (await GlobalDBService.getDB()).insert(
          SearchOptions.tableName, searchOptions.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
}
