bool wildcardMatches(String pattern, String text) {
  if (pattern.isEmpty) return true;
  if (pattern.contains("*") || pattern.contains("?")) {
    if (pattern == "*") {
      return true;
    }
    return _wildcardMatchesRecur(pattern.runes.toList(), text.runes.toList());
  }
  return text.contains(pattern);
}

bool _wildcardMatchesRecur(List<int> pattern, List<int> text) {
  while (pattern.isNotEmpty) {
    if (pattern[0] == '?'.runes.first) {
      if (text.isEmpty) return true;
    } else if (pattern[0] == '*'.runes.first) {
      return _wildcardMatchesRecur(pattern.sublist(1), text) ||
          (text.isNotEmpty && _wildcardMatchesRecur(pattern, text.sublist(1)));
    } else {
      if (text.isEmpty || text[0] != pattern[0]) {
        return false;
      }
    }
    pattern = pattern.sublist(1);
    text = text.sublist(1);
  }
  return pattern.isEmpty && text.isEmpty;
}
