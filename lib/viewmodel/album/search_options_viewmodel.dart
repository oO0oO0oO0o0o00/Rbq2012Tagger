import 'package:flutter/foundation.dart';

import '../../model/global/model.dart';
import '../../service/search_options_service.dart';
import '../../util/inputs.dart';

class SearchOptionsViewModel with ChangeNotifier {
  SearchOptions? _model;

  String get byName => _model?.byName ?? "";

  set byName(String val) {
    final model = _model;
    if (model == null || val == model.byName) return;
    model.byName = val;
    notifyListeners();
    save();
  }

  bool get byNameCase => _model?.byNameCase ?? false;

  set byNameCase(bool value) {
    final model = _model;
    if (model == null || value == model.byNameCase) return;
    model.byNameCase = value;
    notifyListeners();
    save();
  }

  DateTime? get fromTime => _model?.fromTime;

  set fromTime(DateTime? value) {
    final model = _model;
    if (model == null || value == model.fromTime) return;
    model.fromTime = value;
    notifyListeners();
    save();
  }

  DateTime? get toTime => _model?.toTime;

  set toTime(DateTime? value) {
    final model = _model;
    if (model == null || value == model.toTime) return;
    model.toTime = value;
    notifyListeners();
    save();
  }

  String get fromSizeKb => stringifyOptionalInt(_model?.fromSizeKb);

  set fromSizeKb(String value) {
    final model = _model;
    final intVal = parseOptionalInt(value);
    if (model == null || intVal == model.fromSizeKb) return;
    model.fromSizeKb = intVal;
    notifyListeners();
    save();
  }

  String get toSizeKb => stringifyOptionalInt(_model?.toSizeKb);

  set toSizeKb(String value) {
    final model = _model;
    final intVal = parseOptionalInt(value);
    if (model == null || intVal == model.toSizeKb) return;
    model.toSizeKb = intVal;
    notifyListeners();
    save();
  }

  List<String> get tags => _model?.tags ?? const [];

  void addTag(String value) => _addRemoveTagTo(tags, value, remove: false);

  void removeTag(String value) => _addRemoveTagTo(tags, value, remove: true);

  int getTagsCount() => tags.length;

  String getTagAt(int index) => tags[index];

  List<String> get xtags => _model?.xtags ?? const [];

  void addXTag(String value) => _addRemoveTagTo(xtags, value, remove: false);

  void removeXTag(String value) => _addRemoveTagTo(xtags, value, remove: true);

  int getXTagsCount() => xtags.length;

  String getXTagAt(int index) => xtags[index];

  SearchOptionsViewModel();

  SearchOptions? getModel() => _model;

  void setModel(SearchOptions model) {
    _model = model;
    notifyListeners();
  }

  Future<void> save() async {
    final model = _model;
    if (model != null) {
      await SearchOptionsService.save(model);
    }
  }

  void _addRemoveTagTo(List<String> storage, String value,
      {required bool remove}) {
    if (remove) {
      storage.remove(value);
    } else {
      if (storage.contains(value)) return;
      storage.add(value);
    }
    save();
    notifyListeners();
  }
}
