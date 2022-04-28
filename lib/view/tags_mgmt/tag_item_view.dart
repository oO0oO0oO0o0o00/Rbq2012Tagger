import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../model/global/color_spec.dart';
import '../../model/global/model.dart';
import '../../util/platform.dart';
import '../../viewmodel/tag_templates_viewmodel.dart';
import '../commons/color_preview.dart';
import '../commons/dialogs.dart';
import '../commons/simple_list_item.dart';
import 'edit_name_field.dart';
import 'edit_shortcut_field.dart';

/// View for an editable tag in Tags Management page.
class TagItemView extends StatelessWidget {
  final TagTemplatesViewModel viewModel;
  final TagTemplate item;
  final Future<bool> Function(
          BuildContext context, TagTemplatesViewModel viewModel)
      handlePreviousEditing;

  TagItemView(
      {required this.viewModel,
      required this.item,
      required this.handlePreviousEditing})
      : super(key: Key(item.name));

  @override
  Widget build(BuildContext context) {
    return SimpleListItem(
        builder: (hovered) => ChangeNotifierProvider.value(
            value: viewModel,
            builder: (context, child) => Consumer<TagTemplatesViewModel>(
                builder: (context, viewModel, child) =>
                    item.name == viewModel.editingItem?.previous.name
                        ? _buildEditingItem(hovered)
                        : _buildNormalItem(context, hovered))));
  }

  void _commitEditing() => viewModel.commitEditing();

  void _discardEditing() => viewModel.discardEditing();

  void _handleKey(RawKeyEvent e) {
    if (e.isAltPressed ||
        e.isControlPressed ||
        e.isShiftPressed ||
        e.isMetaPressed) return;
    if ([LogicalKeyboardKey.enter.keyId, LogicalKeyboardKey.numpadEnter.keyId]
        .contains(e.logicalKey.keyId)) {
      _commitEditing();
    } else if (LogicalKeyboardKey.escape.keyId == e.logicalKey.keyId) {
      _discardEditing();
    }
  }

  Future<void> _delete(BuildContext context) async {
    if (await showConfirmationDialog(context,
            content: "Delete?", escAsNeutral: false) ??
        false) {
      viewModel.deleteItem(item);
    }
  }

  Widget _buildEditingItem(bool hovered) {
    return Row(children: [
      Expanded(child: EditNameField(viewModel, handleKey: _handleKey)),
      const SizedBox(width: 4),
      const Icon(Icons.keyboard),
      const SizedBox(width: 4),
      SizedBox(
          width: 30,
          child: EditShortcutField(viewModel, handleKey: _handleKey)),
      const SizedBox(width: 4),
      const Icon(Icons.palette),
      const SizedBox(width: 4),
      PopupMenuButton(
          itemBuilder: (context) =>
              [for (final color in ColorSpec.all) _buildColorItem(color)],
          onSelected: (ColorSpec color) =>
              viewModel.editingItem!.current.color = color,
          child: ColorSquare(
              color: viewModel.editingItem!.current.color.background)),
      const SizedBox(width: 16),
      GestureDetector(onTap: _discardEditing, child: const Icon(Icons.clear)),
      GestureDetector(onTap: _commitEditing, child: const Icon(Icons.check)),
      if (isPC()) const Icon(null)
    ]);
  }

  PopupMenuItem<ColorSpec> _buildColorItem(ColorSpec color) {
    return PopupMenuItem<ColorSpec>(
      value: color,
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: color.background),
          child: Text(
            color.name,
            style: TextStyle(color: color.foreground),
          )),
    );
  }

  Widget _buildNormalItem(BuildContext context, bool hovered) {
    return Row(children: [
      ColorSquare(color: item.color.background),
      const SizedBox(width: 12),
      Expanded(
          child: Row(children: [
        Text(item.name),
        const SizedBox(width: 12),
        if (item.shortcut != null) ...[
          const Icon(Icons.keyboard, color: Colors.grey),
          const SizedBox(width: 4),
          Text(item.shortcut!, style: const TextStyle(color: Colors.grey))
        ]
      ])),
      if (hovered) ...[
        GestureDetector(
            onTap: () async {
              if (!await handlePreviousEditing(context, viewModel)) return;
              viewModel.beginEditing(item);
            },
            child: const Icon(Icons.edit)),
        GestureDetector(
            onTap: () async {
              if (!await handlePreviousEditing(context, viewModel)) return;
              viewModel.beginCreateItemAfter(item);
            },
            child: const Icon(Icons.add)),
        GestureDetector(
            onTap: () => _delete(context), child: const Icon(Icons.delete)),
      ],
      if (Platform.isWindows) const Icon(null)
    ]);
  }
}
