import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/keyboard.dart';
import '../../viewmodel/tag_templates_viewmodel.dart';

class EditShortcutField extends StatefulWidget {
  final TagTemplatesViewModel viewModel;
  final Function(RawKeyEvent e) handleKey;

  const EditShortcutField(this.viewModel, {Key? key, required this.handleKey})
      : super(key: key);

  @override
  State<EditShortcutField> createState() => _EditShortcutFieldState();
}

class _EditShortcutFieldState extends State<EditShortcutField> {
  late TextEditingController _controller;
  late final FocusNode _focus;
  String? key;

  @override
  void initState() {
    super.initState();
    key = widget.viewModel.editingItem!.previous.shortcut;
    _controller =
        TextEditingController.fromValue(TextEditingValue(text: key ?? ""));
    _controller.addListener(() {
      final key = this.key ?? "";
      _controller.value = TextEditingValue(
          text: key,
          selection: TextSelection(baseOffset: 0, extentOffset: key.length),
          composing: TextRange.empty);
    });
    _focus = FocusNode(debugLabel: 'editTagShortcutScope');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RawKeyboardListener(
      focusNode: _focus,
      onKey: (e) {
        if (e is! RawKeyDownEvent) return;
        if (!(e.isControlPressed || e.isAltPressed || e.isMetaPressed)) {
          widget.viewModel.editingItem!.current.shortcut =
              key = getSingleKeyShortcut(e.logicalKey.keyLabel);
        }
        // print(key);
        widget.handleKey(e);
      },
      child: TextField(
        maxLines: 1,
        controller: _controller,
        textAlign: TextAlign.center,
      ));
}
