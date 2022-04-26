import 'package:flutter/services.dart';

/// Keyboard-related utilities.

/// Get representation of single key keyboard shortcut from label of logical key.
/// Letter and digit => itself
/// Numpad digit -> "[" + itself + "]"
String? getSingleKeyShortcut(String label) {
  if (_matchesLetter.hasMatch(label)) {
    return label;
  } else if (_matchesDigit.hasMatch(label)) {
    return label;
  } else if (_matchesKeypadDigit.hasMatch(label)) {
    return "[${label[label.length - 1]}]";
  }
  return null;
}

bool isControlPressed() =>
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.controlRight);

bool isShiftPressed() =>
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftRight);

bool isAltPressed() =>
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.altLeft) ||
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.altRight);

bool isMetaPressed() =>
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.metaLeft) ||
    RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.metaRight);

final _matchesLetter = RegExp(r'^\p{Letter}$', unicode: true);
final _matchesDigit = RegExp(r'^\d$', unicode: true);
final _matchesKeypadDigit = RegExp(r'^Numpad \d$', unicode: true);
