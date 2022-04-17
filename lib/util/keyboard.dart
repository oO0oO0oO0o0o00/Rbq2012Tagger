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

final _matchesLetter = RegExp(r'^\p{Letter}$', unicode: true);
final _matchesDigit = RegExp(r'^\d$', unicode: true);
final _matchesKeypadDigit = RegExp(r'^Numpad \d$', unicode: true);
