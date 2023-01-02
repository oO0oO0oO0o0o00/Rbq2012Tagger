import '../named_config.dart';

class TutorialOption implements NamedConfig {
  static const tableName = "batch_action";
  static const colName = "name";
  static const colNameCounter = "counter";

  final String _name;
  int counter = 0;

  TutorialOption({required name}) : _name = name;

  @override
  String get name => _name;

  TutorialOption.fromMap(Map<String, Object?> map)
      : _name = map[colName] as String,
        counter = map[colNameCounter] as int;

  @override
  Map<String, Object?> toMap() => {colName: name, colNameCounter: counter};
}
