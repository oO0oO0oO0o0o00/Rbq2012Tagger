import 'package:sqflite_common/sqlite_api.dart';

import '../model/global/search_options.dart';
import 'named_config_service.dart';

class SearchOptionsService extends NamedConfigService<SearchOptions> {
  static SearchOptionsService instance = SearchOptionsService._();

  SearchOptionsService._();

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
        '${SearchOptions.colXtags} TEXT,'
        '${SearchOptions.colConditionType} TEXT) WITHOUT ROWID');
  }

  @override
  String get tableName => SearchOptions.tableName;

  @override
  SearchOptions buildEmpty({required String name}) => SearchOptions(name: name);

  @override
  SearchOptions fromMap(Map<String, Object?> map) => SearchOptions.fromMap(map);
}
