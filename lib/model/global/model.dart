import 'package:tagger/model/global/color_spec.dart';

class RecentAlbum {
  static const tableName = "recent";
  static const colPath = "path";
  static const colLastOpened = "last_opened";
  static const colPinned = "pinned";

  final String path;
  DateTime lastOpened;
  int get lastOpenedSerialized => lastOpened.millisecondsSinceEpoch;
  bool pinned;

  RecentAlbum(this.path, {required this.lastOpened, required this.pinned});

  RecentAlbum.fromMap(Map<String, Object?> map)
      : path = map[colPath] as String,
        lastOpened =
            DateTime.fromMillisecondsSinceEpoch(map[colLastOpened] as int),
        pinned = (map[colPinned] as int) != 0;

  Map<String, Object?> toMap() => {
        colPath: path,
        colLastOpened: lastOpenedSerialized,
        colPinned: pinned ? 1 : 0
      };
}

class TagTemplateForDB {
  static const String tableName = "tag";
  static const String colName = "name";
  static const String colAfter = "after";
  static const String colShortcut = "shortcut";
  static const colColor = "color";

  final TagTemplate data;
  final String? after;
  TagTemplateForDB? next;

  TagTemplateForDB(this.data, this.after);

  TagTemplateForDB.fromMap(Map<String, Object?> map)
      : data = TagTemplate(
            name: map[colName] as String,
            shortcut: map[colShortcut] as String?,
            color: ColorSpec.getWith(name: map[colColor] as String)),
        after = map[colAfter] as String?;

  Map<String, Object?> toMap({bool hasName = true, bool hasAfter = true}) => {
        if (hasName) colName: data.name,
        colShortcut: data.shortcut,
        if (hasAfter) colAfter: after,
        colColor: data.color.name
      };
}

class TagTemplate {
  String name;
  String? shortcut;
  ColorSpec color;

  TagTemplate.from(TagTemplate another)
      : this(
            name: another.name,
            shortcut: another.shortcut,
            color: another.color);

  TagTemplate({required this.name, this.shortcut, required this.color});
}
