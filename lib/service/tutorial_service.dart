import 'package:sqflite_common/sqlite_api.dart';
import 'package:tagger/service/global_db_service.dart';
import '../model/global/tutorial_option.dart';
import 'named_config_service.dart';

class TutorialService extends NamedConfigService<TutorialOption> {
  static TutorialService instance = TutorialService._();
  static const kDeletionNotice = "deletion_notice";

  TutorialService._();

  static Future<void> createTable(Database db, int version) async {
    await db.execute('CREATE TABLE ${TutorialOption.tableName} ('
        '${TutorialOption.colName} TEXT PRIMARY KEY,'
        '${TutorialOption.colCounter} INT) WITHOUT ROWID');
  }

  @override
  TutorialOption buildEmpty({required String name}) => TutorialOption(name: name);

  @override
  TutorialOption fromMap(Map<String, Object?> map) => TutorialOption.fromMap(map);

  Future<bool> shouldShow(String name, int maxCount, {bool increase = false}) async {
    final result = await get(name);
    if ((result?.counter ?? 0) >= maxCount) return false;
    if (increase) await _increase(name, result);
    return true;
  }

  Future<void> increase(String name) async => await _increase(name, await get(name));

  // It does not have to be atomic.
  Future<void> _increase(String name, TutorialOption? model) async {
    final modelValue = model ?? buildEmpty(name: name);
    modelValue.counter += 1;
    await save(modelValue);
  }

  @override
  String get tableName => TutorialOption.tableName;
}
