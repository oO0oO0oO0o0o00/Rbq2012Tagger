import 'package:flutter/foundation.dart';

import '../../model/global/search_options.dart';
import '../../service/search_options_service.dart';
import '../../util/inputs.dart';

class SearchOptionsViewModel with ChangeNotifier {
  SearchOptions? _model;

  String get byName => _model?.byName ?? "";

  set byName(String value) {
    if (value == _model?.byName) return;
    _model?.byName = value;
    save();
  }

  bool get byNameCase => _model?.byNameCase ?? false;

  set byNameCase(bool value) {
    if (value == _model?.byNameCase) return;
    _model?.byNameCase = value;
    save();
  }

  DateTime? get fromTime => _model?.fromTime;

  set fromTime(DateTime? value) {
    if (value == _model?.fromTime) return;
    _model?.fromTime = value;
    save();
  }

  DateTime? get toTime => _model?.toTime;

  set toTime(DateTime? value) {
    if (value == _model?.toTime) return;
    _model?.toTime = value;
    save();
  }

  String get fromSizeKb => stringifyOptionalInt(_model?.fromSizeKb);

  set fromSizeKb(String value) {
    final intVal = parseOptionalInt(value);
    if (intVal == _model?.fromSizeKb) return;
    _model?.fromSizeKb = intVal;
    save();
  }

  String get toSizeKb => stringifyOptionalInt(_model?.toSizeKb);

  set toSizeKb(String value) {
    final intVal = parseOptionalInt(value);
    if (intVal == _model?.toSizeKb) return;
    _model?.toSizeKb = intVal;
    save();
  }

  List<String> get _tags => _model?.tags ?? const [];

  void addTag(String value) => _addRemoveTagTo(_tags, value, remove: false);

  void removeTag(String value) => _addRemoveTagTo(_tags, value, remove: true);

  int getTagsCount() => _tags.length;

  String getTagAt(int index) => _tags[index];

  List<String> get _xtags => _model?.xtags ?? const [];

  void addXTag(String value) => _addRemoveTagTo(_xtags, value, remove: false);

  void removeXTag(String value) => _addRemoveTagTo(_xtags, value, remove: true);

  int getXTagsCount() => _xtags.length;

  String getXTagAt(int index) => _xtags[index];

  String get conditionType => _model?.conditionType ?? SearchOptionsConditionType.defaultValue;

  set conditionType(String value) {
    if (value == _model?.conditionType) return;
    _model?.conditionType = value;
    save();
  }

  SearchOptionsViewModel();

  SearchOptions? getModel() => _model;

  void setModel(SearchOptions model) {
    _model = model;
    notifyListeners();
  }

  Future<void> save() async {
    final model = _model;
    if (model != null) {
      await SearchOptionsService.instance.save(model);
      notifyListeners();
    }
  }

  void _addRemoveTagTo(List<String> storage, String value, {required bool remove}) {
    if (remove) {
      storage.remove(value);
    } else {
      if (storage.contains(value)) return;
      storage.add(value);
    }
    save();
  }
}
