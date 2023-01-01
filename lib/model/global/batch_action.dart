import 'dart:convert';

import '../named_config.dart';

class BatchAction implements NamedConfig {
  static const tableName = "batch_action";
  static const colName = "name";
  static const colEnableMoveCopyAction = "enable_move_copy_action";
  static const colSelectionOnly = "selection_only";
  static const colCopy = "copy";
  static const colPath = "path";
  static const colEnableTaggingAction = "enable_tagging_action";
  static const colTags = "tags";
  static const colXtags = "xtags";

  final String _name;
  bool enableMoveCopyAction = true;
  bool selectionOnly = true;
  bool copy = false;
  String? path;
  bool enableTaggingAction = false;
  List<String> tags = [];
  List<String> xtags = [];

  BatchAction({required name}) : _name = name;

  @override
  String get name => _name;

  BatchAction.fromMap(Map<String, Object?> map)
      : _name = map[colName] as String,
        enableMoveCopyAction = map[colEnableMoveCopyAction] as int != 0,
        selectionOnly = map[colSelectionOnly] as int != 0,
        copy = map[colCopy] as int != 0,
        path = map[colPath] as String?,
        enableTaggingAction = map[colEnableTaggingAction] as int != 0,
        tags = (jsonDecode(map[colTags] as String? ?? "[]") as List).map((e) => e as String).toList(),
        xtags = (jsonDecode(map[colXtags] as String? ?? "[]") as List).map((e) => e as String).toList();

  @override
  Map<String, Object?> toMap() => {
        colName: name,
        colEnableMoveCopyAction: enableMoveCopyAction ? 1 : 0,
        colSelectionOnly: selectionOnly ? 1 : 0,
        colCopy: copy ? 1 : 0,
        colPath: path,
        colEnableTaggingAction: enableTaggingAction ? 1 : 0,
        colTags: jsonEncode(tags),
        colXtags: jsonEncode(xtags)
      };
}
