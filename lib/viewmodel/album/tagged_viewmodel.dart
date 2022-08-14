import 'package:flutter/cupertino.dart';

import '../../model/global/color_spec.dart';
import '../../model/global/model.dart';

/// View model that associates a tag with a potential tag template.
class TaggedViewModel with ChangeNotifier {
  final String tag;
  TagTemplate? template;

  TaggedViewModel(this.tag, {this.template});

  ColorSpec getColor() => template?.color ?? ColorSpec.grey;
}
