import 'dart:io';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:tagger/util/image_util.dart';
import 'package:tuple/tuple.dart';
import 'package:filesize/filesize.dart';

import '../../model/file_conflict_resolve_config.dart';
import 'checkbox_row.dart';

Future<Map<String, FileConflictAction>?> showFileConflictResolvingDialog(
    BuildContext context, List<Tuple2<File, File>> conflicts) async {
  final x = await showDialog<Map<String, FileConflictAction>>(
      context: context, builder: (ctx) => FileConflictResolvingDialog(conflicts));
  return x;
}

class FileConflictResolvingDialog extends StatefulWidget {
  final List<Tuple2<File, File>> conflicts;
  const FileConflictResolvingDialog(this.conflicts, {Key? key}) : super(key: key);

  @override
  State<FileConflictResolvingDialog> createState() => _FileConflictResolvingDialogState();
}

class _FileConflictResolvingDialogState extends State<FileConflictResolvingDialog> {
  late final List<FileConflictAction> selections = List.filled(widget.conflicts.length, FileConflictAction.skip);
  List<Tuple2<FileStat, FileStat>>? stats;
  List<bool>? areIdentical;
  bool skipIdenticalPairs = false;
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (this.stats != null) return;
    final stats =
        await Future.wait(widget.conflicts.map((e) async => Tuple2(await e.item1.stat(), await e.item2.stat())));
    final areIdentical =
        stats.map((e) => e.item1.modified == e.item2.modified && e.item1.size == e.item2.size).toList();
    setState(() {
      this.stats = stats;
      this.areIdentical = areIdentical;
    });
  }

  @override
  Widget build(BuildContext context) {
    final identicalCount = areIdentical?.where((e) => e).length ?? 0;
    return AlertDialog(
      title: const Text("File conflicts"),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              _buildSelectAllView("Use new files", FileConflictAction.overwrite, FileConflictAction.skip),
              _buildSelectAllView("Keep existing files", FileConflictAction.skip, FileConflictAction.overwrite)
            ]),
            ListView.builder(
              itemCount: selections.length,
              shrinkWrap: true,
              itemBuilder: ((context, index) => Row(
                    children: (skipIdenticalPairs && areIdentical != null && areIdentical![index])
                        ? []
                        : [
                            Expanded(
                              child: _ConflictItem(
                                  selections[index] != FileConflictAction.skip,
                                  widget.conflicts[index].item1,
                                  stats?[index].item1,
                                  (checked) => setState(() => _updateSelection(
                                      index, checked, FileConflictAction.overwrite, FileConflictAction.skip))),
                            ),
                            Expanded(
                              child: _ConflictItem(
                                  selections[index] != FileConflictAction.overwrite,
                                  widget.conflicts[index].item2,
                                  stats?[index].item2,
                                  (checked) => setState(() => _updateSelection(
                                      index, checked, FileConflictAction.skip, FileConflictAction.overwrite))),
                            ),
                          ],
                  )),
            ),
            if (identicalCount > 0)
              CheckboxRow(
                onChanged: (value) => setState((() => skipIdenticalPairs = value!)),
                child: Text("Skip $identicalCount pair of files having identical modified dates and sizes"),
                value: skipIdenticalPairs,
              )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Abort'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, <String, FileConflictAction>{
            for (var pair in zip([widget.conflicts, selections]))
              (pair[0] as Tuple2<File, File>).item2.path: pair[1] as FileConflictAction
          }),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildSelectAllView(String text, FileConflictAction trueAction, FileConflictAction falseAction) {
    return Expanded(
      child: CheckboxRow(
          value: selections.any((element) => element != falseAction)
              ? (selections.contains(falseAction) ? null : true)
              : false,
          tristate: true,
          onChanged: (value) => setState(() => _updateSelection(null, value ?? false, trueAction, falseAction)),
          child: Text(text)),
    );
  }

  void _updateSelection(int? index, bool checked, FileConflictAction keepAction, FileConflictAction flipAction) {
    if (index == null) {
      for (int i = 0; i < selections.length; i++) {
        _updateSelection(i, checked, keepAction, flipAction);
      }
      return;
    }
    selections[index] =
        checked ? (selections[index] == keepAction ? FileConflictAction.skip : FileConflictAction.rename) : flipAction;
  }
}

class _ConflictItem extends StatelessWidget {
  final bool checked;
  final File file;
  final FileStat? stat;
  final void Function(bool value) onChanged;
  const _ConflictItem(this.checked, this.file, this.stat, this.onChanged);
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxRow(
            value: checked,
            child: Text(
              path.basename(file.path),
              overflow: TextOverflow.ellipsis,
            ),
            onChanged: (value) => onChanged(value!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                stat == null ? "" : DateFormat("yy/MM/dd hh:mm:ss").format(stat!.modified),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                stat == null ? "" : filesize(stat!.size),
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
          if (isImageExtension(file.path))
            SizedBox(
                height: 100,
                width: 200,
                child: FittedBox(clipBehavior: Clip.hardEdge, fit: BoxFit.fitWidth, child: Image.file(file))),
        ],
      );
}
