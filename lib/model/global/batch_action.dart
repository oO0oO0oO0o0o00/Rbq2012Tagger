import 'dart:convert';

import '../named_config.dart';

class BatchActionConditionType {
  static const and = "and";
  static const or = "or";
  static const defaultValue = and;
  static const all = {and: and, or: or};
  static String validate(String? value) => all[value] ?? and;
}

class BatchActionActionType {
  static const add = "add";
  static const remove = "remove";
  static const replace = "replace";
  static const defaultValue = add;
  static const all = {add: add, remove: remove, replace: replace};
  static String validate(String? value) => all[value] ?? add;
}

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
  static const colConditionType = "condition_type";
  static const colActionType = "action_type";

  final String _name;
  bool enableMoveCopyAction;
  bool selectionOnly;
  bool copy;
  String? path;
  bool enableTaggingAction;
  List<String> tags;
  List<String> xtags;
  String conditionType;
  String actionType;

  BatchAction(
      {required name,
      this.enableMoveCopyAction = true,
      this.selectionOnly = true,
      this.copy = false,
      this.path,
      this.enableTaggingAction = false,
      this.tags = const [],
      this.xtags = const [],
      this.conditionType = BatchActionConditionType.defaultValue,
      this.actionType = BatchActionActionType.add})
      : _name = name;

  @override
  String get name => _name;

  BatchAction.fromMap(Map<String, Object?> map)
      : _name = map[colName] as String,
        enableMoveCopyAction = map[colEnableMoveCopyAction] as int != 0,
        selectionOnly = map[colSelectionOnly] as int != 0,
        copy = map[colCopy] as int != 0,
        path = map[colPath] as String?,
        enableTaggingAction = map[colEnableTaggingAction] as int != 0,
        tags = (jsonDecode(map[colTags] as String? ?? "[]") as List)
            .map((e) => e as String)
            .toList(),
        xtags = (jsonDecode(map[colXtags] as String? ?? "[]") as List)
            .map((e) => e as String)
            .toList(),
        conditionType =
            BatchActionConditionType.validate(map[colConditionType] as String?),
        actionType =
            BatchActionActionType.validate(map[colActionType] as String?);

  @override
  Map<String, Object?> toMap() => {
        colName: name,
        colEnableMoveCopyAction: enableMoveCopyAction ? 1 : 0,
        colSelectionOnly: selectionOnly ? 1 : 0,
        colCopy: copy ? 1 : 0,
        colPath: path,
        colEnableTaggingAction: enableTaggingAction ? 1 : 0,
        colTags: jsonEncode(tags),
        colXtags: jsonEncode(xtags),
        colConditionType: conditionType,
        colActionType: actionType
      };
}
