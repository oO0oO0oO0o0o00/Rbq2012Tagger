abstract class NamedConfig {
  String get name;

  NamedConfig(String name);

  NamedConfig.fromMap(Map<String, Object?> map);

  Map<String, Object?> toMap();
}
