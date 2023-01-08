import '../named_config.dart';

class TutorialOption implements NamedConfig {
  static const tableName = "tutorial_option";
  static const colName = "name";
  static const colCounter = "counter";

  final String _name;
  int counter = 0;

  TutorialOption({required name}) : _name = name;

  @override
  String get name => _name;

  TutorialOption.fromMap(Map<String, Object?> map)
      : _name = map[colName] as String,
        counter = map[colCounter] as int;

  @override
  Map<String, Object?> toMap() => {colName: name, colCounter: counter};
}
