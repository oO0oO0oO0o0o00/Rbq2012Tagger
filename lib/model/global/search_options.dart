import 'dart:convert';

import '../named_config.dart';

class SearchOptions implements NamedConfig {
  static const tableName = "search_options";
  static const colName = "name";
  static const colByName = "by_name";
  static const colByNameCase = "by_name_case";
  static const colFromTime = "from_time";
  static const colToTime = "to_time";
  static const colFromSizeKb = "from_size_kb";
  static const colToSizeKb = "to_size_kb";
  // Not indexed && always save/load altogether.
  // Using json string instead of associated table.
  static const colTags = "tags";
  static const colXtags = "xtags";

  final String name;
  String? byName;
  bool? byNameCase;
  DateTime? fromTime;
  DateTime? toTime;
  int? fromSizeKb;
  int? toSizeKb;
  List<String> tags;
  List<String> xtags;

  SearchOptions(
      {required this.name,
      this.byName,
      this.byNameCase,
      this.fromTime,
      this.toTime,
      this.fromSizeKb,
      this.toSizeKb,
      this.tags = const [],
      this.xtags = const []});

  SearchOptions.fromMap(Map<String, Object?> map)
      : name = map[colName] as String,
        byName = map[colByName] as String?,
        byNameCase = map[colByNameCase] == null
            ? null
            : (map[colByNameCase] as int != 0),
        fromTime = map[colFromTime] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map[colFromTime] as int),
        toTime = map[colToTime] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map[colToTime] as int),
        fromSizeKb = map[colFromSizeKb] as int?,
        toSizeKb = map[colToSizeKb] as int?,
        tags = (jsonDecode(map[colTags] as String? ?? "[]") as List)
            .map((e) => e as String)
            .toList(),
        xtags = (jsonDecode(map[colXtags] as String? ?? "[]") as List)
            .map((e) => e as String)
            .toList();

  Map<String, Object?> toMap() => {
        colName: name,
        colByName: byName,
        colByNameCase: byNameCase,
        colFromTime: fromTime?.millisecondsSinceEpoch,
        colToTime: toTime?.millisecondsSinceEpoch,
        colFromSizeKb: fromSizeKb,
        colToSizeKb: toSizeKb,
        colTags: jsonEncode(tags),
        colXtags: jsonEncode(xtags)
      };
}
