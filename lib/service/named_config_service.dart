import '../model/named_config.dart';
import 'global_db_service.dart';
import 'package:sqflite_common/sqlite_api.dart';

abstract class NamedConfigService<T extends NamedConfig> {
  String get tableName;

  T buildEmpty({required String name});

  T fromMap(Map<String, Object?> map);

  Future<T> getDefault() async {
    return await get("") ?? buildEmpty(name: "");
  }

  Future<T?> get(String name) async {
    var list = await (await GlobalDBService.getDB()).query(tableName,
        distinct: true, where: "name == ?", whereArgs: [name]);
    return list.isEmpty ? null : fromMap((list).first);
  }

  Future<void> save(T namedConfig) async =>
      await (await GlobalDBService.getDB()).insert(
          tableName, namedConfig.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
}
