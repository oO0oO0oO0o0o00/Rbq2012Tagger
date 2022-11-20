import 'package:flutter/foundation.dart';

import '../model/global/batch_action.dart';
import '../model/global/model.dart';
import '../service/batch_action_service.dart';
import 'homepage_viewmodel.dart';

class BatchActionViewModel with ChangeNotifier {
  BatchAction? _model;
  HomePageViewModel homePageViewModel;
  RecentAlbum? _currentPath;

  BatchActionViewModel(this.homePageViewModel);

  String? get name => _model?.name;

  BatchAction? getModel() => _model;

  void setModel(BatchAction model) {
    _model = model;
    notifyListeners();
  }

  bool get selectionOnly => _model?.selectionOnly ?? false;

  set selectionOnly(bool value) {
    if (value == _model?.selectionOnly) return;
    _model?.selectionOnly = value;
    save();
  }

  bool get enableMoveCopyAction => _model?.enableMoveCopyAction ?? true;

  set enableMoveCopyAction(bool value) {
    if (value == _model?.enableMoveCopyAction) return;
    _model?.enableMoveCopyAction = value;
    save();
  }

  bool get copy => _model?.copy ?? false;

  set copy(bool value) {
    if (value == _model?.copy) return;
    _model?.copy = value;
    save();
  }

  RecentAlbum? get path {
    var currentPath = _model?.path;
    if (currentPath == null) return null;
    if (currentPath == _currentPath?.path) return _currentPath;
    var result = _currentPath = homePageViewModel.getByPath(currentPath);
    return result;
  }

  set path(RecentAlbum? value) {
    if (value?.path == _model?.path) return;
    _model?.path = value?.path;
    _currentPath = value;
    save();
  }

  void setPath(String path) {
    if (_model?.path == path) return;
    final result = _currentPath = homePageViewModel.getByPath(path);
    _model?.path = result?.path;
    save();
  }

  bool get enableTaggingAction => _model?.enableTaggingAction ?? false;

  set enableTaggingAction(bool value) {
    if (value == _model?.enableTaggingAction) return;
    _model?.enableTaggingAction = value;
    save();
  }

  List<String> get _tags => _model?.tags ?? const [];

  String get conditionType =>
      _model?.conditionType ?? BatchActionConditionType.defaultValue;

  set conditionType(String value) {
    if (value == _model?.conditionType) return;
    _model?.conditionType = value;
    save();
  }

  String get actionType =>
      _model?.actionType ?? BatchActionActionType.defaultValue;

  set actionType(String value) {
    if (value == _model?.actionType) return;
    _model?.actionType = value;
    save();
  }

  void addTag(String value) => _addRemoveTagTo(_tags, value, remove: false);

  void removeTag(String value) => _addRemoveTagTo(_tags, value, remove: true);

  int getTagsCount() => _tags.length;

  String getTagAt(int index) => _tags[index];

  List<String> get _xtags => _model?.xtags ?? const [];

  void addXTag(String value) => _addRemoveTagTo(_xtags, value, remove: false);

  void removeXTag(String value) => _addRemoveTagTo(_xtags, value, remove: true);

  int getXTagsCount() => _xtags.length;

  String getXTagAt(int index) => _xtags[index];

  Future<void> save() async {
    final model = _model;
    if (model != null) {
      await BatchActionService.instance.save(model);
    }
    notifyListeners();
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
