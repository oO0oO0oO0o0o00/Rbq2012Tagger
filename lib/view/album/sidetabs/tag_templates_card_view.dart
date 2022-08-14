import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../commons/keystroke_view.dart';
import '../../commons/scalable_card_view.dart';
import '../tag_templates_view.dart';

/// Tag templates panel.
class TagTemplatesCardView extends StatelessWidget {
  const TagTemplatesCardView({
    Key? key,
    required this.onClickTag,
  }) : super(key: key);

  final Function(String tag) onClickTag;

  @override
  Widget build(BuildContext context) {
    return ScalableCardView(children: [
      Text(
        "Tag Templates",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 24),
      TagTemplatesView(onClickTag: onClickTag),
      const SizedBox(height: 16),
      Column(mainAxisSize: MainAxisSize.min, children: const [
        _KeystrokesNoteView(
            keyStrokes: [LogicalKeyboardKey.alt], text: "removal mode"),
        _KeystrokesNoteView(
            keyStrokes: [LogicalKeyboardKey.shift], text: "auto select next"),
        _KeystrokesNoteView(keyStrokes: [
          LogicalKeyboardKey.arrowUp,
          LogicalKeyboardKey.arrowLeft,
          LogicalKeyboardKey.arrowDown,
          LogicalKeyboardKey.arrowRight
        ], text: "navigate"),
      ])
    ]);
  }
}

/// Explanation for one or more keystroke.
class _KeystrokesNoteView extends StatelessWidget {
  const _KeystrokesNoteView({
    Key? key,
    required this.keyStrokes,
    required this.text,
  }) : super(key: key);
  final List<LogicalKeyboardKey> keyStrokes;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final keyStroke in keyStrokes) ...[
            KeystrokeView(keystroke: keyStroke),
            const SizedBox(width: 4),
          ],
          const SizedBox(width: 4),
          Text(text)
        ],
      ));
}
