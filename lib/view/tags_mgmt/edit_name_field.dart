import 'package:flutter/material.dart';

import '../../viewmodel/tag_templates_viewmodel.dart';

class EditNameField extends StatefulWidget {
  final TagTemplatesViewModel viewModel;
  final Function(RawKeyEvent e) handleKey;

  const EditNameField(this.viewModel, {Key? key, required this.handleKey})
      : super(key: key);

  @override
  State<EditNameField> createState() => _EditNameFieldState();
}

class _EditNameFieldState extends State<EditNameField> {
  late TextEditingController _controller;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController.fromValue(TextEditingValue(
        text: widget.viewModel.editingItem?.current.name ?? ""));
    _controller.addListener(() {
      widget.viewModel.editingItem!.current.name = _controller.text;
    });
    _focus = FocusNode(debugLabel: 'editTagScope');
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
      onKey: widget.handleKey,
      child: TextField(
          autofocus: true,
          maxLines: 1,
          controller: _controller,
          decoration: InputDecoration(
              hintText: widget.viewModel.editingItem!.isInsertionMode
                  ? 'name the tag'
                  : 'rename tag "${widget.viewModel.editingItem!.previous.name}"...',
              errorText: widget.viewModel.editingItem?.errorText)));
}
