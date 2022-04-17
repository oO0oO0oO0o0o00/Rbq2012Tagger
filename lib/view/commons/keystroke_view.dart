import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeystrokeView extends StatelessWidget {
  const KeystrokeView({Key? key, required this.keystroke}) : super(key: key);
  final LogicalKeyboardKey keystroke;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.textTheme.bodyMedium?.color,
      borderRadius: BorderRadius.circular(6),
      child: _resolveKeystroke(keystroke, theme),
    );
  }
}

Widget _resolveKeystroke(LogicalKeyboardKey key, ThemeData theme) {
  if (key == LogicalKeyboardKey.arrowLeft) {
    return _buildIcon(Icons.arrow_back, theme);
  }
  if (key == LogicalKeyboardKey.arrowRight) {
    return _buildIcon(Icons.arrow_forward, theme);
  }
  if (key == LogicalKeyboardKey.arrowUp) {
    return _buildIcon(Icons.arrow_upward, theme);
  }
  if (key == LogicalKeyboardKey.arrowDown) {
    return _buildIcon(Icons.arrow_downward, theme);
  }
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        key.keyLabel,
        style: TextStyle(
            color: theme.cardColor,
            fontSize: theme.textTheme.bodySmall?.fontSize),
      ));
}

Widget _buildIcon(IconData iconData, ThemeData theme) => Padding(
    padding: const EdgeInsets.all(4),
    child: Icon(
      iconData,
      color: theme.cardColor,
      size: 16,
    ));
