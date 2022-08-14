import 'dart:io';

import 'search_options_service.dart';
import 'tag_templates_service.dart';
import 'recent_albums_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart' as path;

/// Service for app-wide database.
class GlobalDBService {
  static const _schemaVersion = 2;

  static String get _dbPath =>
      path.join(File(Platform.resolvedExecutable).parent.path, "app.db");

  static Database? _db;

  static Future<Database> getDB() async {
    sqfliteFfiInit();
    return _db ??= await databaseFactoryFfi.openDatabase(_dbPath,
        options: OpenDatabaseOptions(
            version: _schemaVersion,
            onCreate: (db, version) async {
              await RecentAlbumsService.createTable(db, version);
              await TagTemplatesService.createTable(db, version);
              await SearchOptionsService.createTable(db, version);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              switch (oldVersion) {
                case 1:
                  await SearchOptionsService.createTable(db, newVersion);
                  break;
                default:
                  throw "wtf";
              }
            }));
  }
}
