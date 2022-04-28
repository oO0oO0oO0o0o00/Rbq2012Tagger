import '../../model/global/model.dart';

/// View model that associates a tag with a potential tag template.
class TaggedViewModel {
  final String tag;
  TagTemplate? template;

  TaggedViewModel(this.tag, {this.template});
}
