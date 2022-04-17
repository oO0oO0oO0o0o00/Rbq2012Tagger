import 'package:flutter/material.dart';
import '../commons/tag_view.dart';
import '../../viewmodel/album/tagged_viewmodel.dart';

class AlbumItemTagView extends StatelessWidget {
  final TaggedViewModel item;
  final Function(String tag) onClose;

  const AlbumItemTagView({Key? key, required this.item, required this.onClose})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(10);
    final backgroundColor = item.template?.color.background ?? Colors.grey;
    return TagView(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            item.tag,
            style: TextStyle(color: item.template?.color.foreground),
          ),
          const SizedBox(width: 8),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: border,
                  // iconSize: 12,
                  onTap: () {
                    onClose(item.tag);
                  },
                  child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 12,
                      ))))
        ]),
        onTap: () {},
        backgroundColor: backgroundColor);
  }
}
