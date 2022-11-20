import 'package:flutter/widgets.dart';

extension TextEditingControllerStableSetter on TextEditingController {
  void setTextIfDifferent(String text) {
    if (this.text != text) this.text = text;
  }
}
