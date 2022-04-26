import 'package:flutter/foundation.dart';

import 'global_db_service.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../model/global/model.dart';

/// Service for user-defined tag templates.
class TagTemplatesService {
  static Future<void> createTable(Database db, int version) async {
    await db.execute('CREATE TABLE ${TagTemplateForDB.tableName} ('
        '${TagTemplateForDB.colName} TEXT PRIMARY KEY, '
        '${TagTemplateForDB.colShortcut} TEXT NULLABLE, '
        '${TagTemplateForDB.colColor} TEXT, '
        '${TagTemplateForDB.colAfter} TEXT NULLABLE) WITHOUT ROWID');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS ${TagTemplateForDB.colShortcut} '
        'ON ${TagTemplateForDB.tableName} (${TagTemplateForDB.colShortcut})');
    await db.execute('CREATE INDEX IF NOT EXISTS ${TagTemplateForDB.colAfter} '
        'ON ${TagTemplateForDB.tableName} (${TagTemplateForDB.colAfter})');
  }

  static Future<List<TagTemplate>> getAll() async {
    // Get a list of all tag templates and convert to name-to-object map.
    final map = Map.fromEntries((await (await GlobalDBService.getDB())
            .query(TagTemplateForDB.tableName))
        .map((e) {
      final model = TagTemplateForDB.fromMap(e);
      return MapEntry(model.data.name, model);
    }));
    // Instead of using recursive mysql query,
    // simply restore the linked list order here.
    // As it can be expected that N(tagTemplates) <= C
    // (there won't be too many tag templates),
    // O(n) => O(C).
    TagTemplateForDB? node;
    List<TagTemplate> list = [];
    map.forEach((key, value) {
      map[value.after]?.next = value;
      if (value.after == null) {
        node = value;
      }
    });
    while (node != null) {
      list.add(node!.data);
      node = node!.next;
    }
    // These debug code should be removed after ensuring the consistency
    // of manipulations over the linked list structure.
    if (list.length != map.length) {
      debugPrint("WTF");
      map.forEach((key, value) {
        debugPrint("${value.data.name} is after ${value.after}");
      });
      return map.entries.map((pair) => pair.value.data).toList();
    }
    return list;
  }

  /// Move (reorder) a tag template.
  /// Updates to other fields shall be done with [update].
  static Future<void> move(TagTemplate item, String? after) async {
    await (await GlobalDBService.getDB()).transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ${TagTemplateForDB.tableName}'
          '  SET ${TagTemplateForDB.colAfter} = ('
          '    SELECT ${TagTemplateForDB.colAfter} '
          '      FROM ${TagTemplateForDB.tableName}'
          '      WHERE ${TagTemplateForDB.colName} == ?'
          '  ) WHERE ${TagTemplateForDB.colAfter} == ?',
          [item.name, item.name]);
      await txn.update(
          TagTemplateForDB.tableName, {TagTemplateForDB.colAfter: after},
          where: "${TagTemplateForDB.colName} == ?", whereArgs: [item.name]);
      await txn.update(
          TagTemplateForDB.tableName, {TagTemplateForDB.colAfter: item.name},
          where: "${TagTemplateForDB.colAfter} "
              "${after == null ? 'IS NULL' : '== ?'} "
              "AND ${TagTemplateForDB.colName} != ?",
          whereArgs: [if (after != null) after, item.name]);
    });
  }

  /// Update a tag template. Reordering shall be done using [move].
  static Future<bool> update(TagTemplate old, TagTemplate updated) async {
    bool ok = false;
    await (await GlobalDBService.getDB()).transaction((txn) async {
      await txn.update(
          TagTemplateForDB.tableName, {TagTemplateForDB.colAfter: updated.name},
          where: "${TagTemplateForDB.colAfter} == ?", whereArgs: [old.name]);
      ok = (await txn.update(TagTemplateForDB.tableName,
              TagTemplateForDB(updated, null).toMap(hasAfter: false),
              where: "${TagTemplateForDB.colName} == ?",
              whereArgs: [old.name])) ==
          1;
    });
    return ok;
  }

  static Future<bool> insert(TagTemplate item, String? after) async {
    try {
      await (await GlobalDBService.getDB()).transaction((txn) async {
        await txn.update(
            TagTemplateForDB.tableName, {TagTemplateForDB.colAfter: item.name},
            where: "${TagTemplateForDB.colAfter}"
                " ${after == null ? 'IS NULL' : '== ?'}",
            whereArgs: [if (after != null) after]);
        await txn.insert(
            TagTemplateForDB.tableName, TagTemplateForDB(item, after).toMap());
      });
    } catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> remove(TagTemplate item) async {
    bool ok = false;
    await (await GlobalDBService.getDB()).transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ${TagTemplateForDB.tableName}'
          '  SET ${TagTemplateForDB.colAfter} = ('
          '    SELECT ${TagTemplateForDB.colAfter}'
          '      FROM ${TagTemplateForDB.tableName}'
          '      WHERE ${TagTemplateForDB.colName} == ?'
          '  ) WHERE ${TagTemplateForDB.colAfter} == ?',
          [item.name, item.name]);
      ok = await txn.delete(TagTemplateForDB.tableName,
              where: "${TagTemplateForDB.colName} == ?",
              whereArgs: [item.name]) ==
          1;
    });
    return ok;
  }
}
