import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tagger/service/tutorial_service.dart';

import 'batch_action_service.dart';
import 'recent_albums_service.dart';
import 'search_options_service.dart';
import 'tag_templates_service.dart';

/// Service for app-wide database.
class GlobalDBService {
  static const _schemaVersion = 7;

  static String get _dbPath => path.join(File(Platform.resolvedExecutable).parent.path, "app.db");

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
              await BatchActionService.createTable(db, version);
              await TutorialService.createTable(db, version);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              switch (oldVersion) {
                case 6:
                  await TutorialService.createTable(db, newVersion);
                  break;
                default:
                  throw "wtf";
              }
            }));
  }
}
