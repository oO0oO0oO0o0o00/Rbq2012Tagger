import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/album/album_viewmodel.dart';
import '../commons/keystroke_view.dart';
import '../commons/scalable_card_view.dart';
import 'tag_template_item_view.dart';

/// Tag templates panel.
class TagTemplatesView extends StatelessWidget {
  const TagTemplatesView({
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
      Consumer<AlbumViewModel>(
          builder: ((context, albumViewModel, child) => Tags(
                itemCount: albumViewModel.tagTemplates.getItemsCount(),
                itemBuilder: (int index) {
                  final item = albumViewModel.tagTemplates.getItem(index);
                  return TagTemplateItemView(
                    item: item,
                    onTap: () => onClickTag(item.name),
                  );
                },
              ))),
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
