import 'dart:io';

import 'tag_templates_service.dart';
import 'recent_albums_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart' as path;

class GlobalDBService {
  static const schemaVersion = 1;

  static String get _dbPath =>
      path.join(File(Platform.resolvedExecutable).parent.path, "app.db");

  static Database? _db;

  static Future<Database> getDB() async {
    sqfliteFfiInit();
    return _db ??= await databaseFactoryFfi.openDatabase(_dbPath,
        options: OpenDatabaseOptions(
            version: schemaVersion,
            onCreate: (db, version) async {
              await RecentAlbumsService.createTable(db, version);
              await TagTemplatesService.createTable(db, version);
            }));
  }
}
