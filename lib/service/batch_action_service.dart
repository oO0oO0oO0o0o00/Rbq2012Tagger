import '../model/global/batch_action.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'named_config_service.dart';

class BatchActionService extends NamedConfigService<BatchAction> {
  static BatchActionService instance = BatchActionService._();

  BatchActionService._();

  static Future<void> createTable(Database db, int version) async {
    await db.execute('CREATE TABLE ${BatchAction.tableName} ('
        '${BatchAction.colName} TEXT PRIMARY KEY,'
        '${BatchAction.colEnableMoveCopyAction} INT,'
        '${BatchAction.colSelectionOnly} INT,'
        '${BatchAction.colCopy} INT,'
        '${BatchAction.colPath} TEXT,'
        '${BatchAction.colEnableTaggingAction} INT,'
        '${BatchAction.colTags} TEXT,'
        '${BatchAction.colXtags} TEXT) WITHOUT ROWID');
  }

  @override
  BatchAction buildEmpty({required String name}) => BatchAction(name: name);

  @override
  BatchAction fromMap(Map<String, Object?> map) => BatchAction.fromMap(map);

  @override
  String get tableName => BatchAction.tableName;
}
