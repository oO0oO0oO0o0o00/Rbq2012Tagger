import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows an async confirmation dialog.
Future<bool?> showConfirmationDialog(BuildContext context,
    {String? title,
    required String content,
    bool barrierDismissible = false,
    bool hasNeutralButton = false,
    bool hasNegativeButton = true,
    bool? escAsNeutral,
    bool acceptEnter = true}) {
  return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ConfirmationDialog(
            title: title,
            content: content,
            hasNeutralButton: hasNeutralButton,
            hasNegativeButton: hasNegativeButton,
            escAsNeutral: escAsNeutral,
            acceptEnter: acceptEnter,
          ),
      barrierDismissible: barrierDismissible);
}

class ConfirmationDialog extends StatefulWidget {
  final String? title;
  final String content;
  final bool hasNeutralButton;
  final bool hasNegativeButton;
  final bool? escAsNeutral;
  final bool acceptEnter;

  const ConfirmationDialog(
      {Key? key,
      required this.title,
      required this.content,
      required this.hasNeutralButton,
      required this.hasNegativeButton,
      this.escAsNeutral,
      this.acceptEnter = true})
      : super(key: key);

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode(debugLabel: 'dialogScope');
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
        focusNode: _focus,
        autofocus: true,
        onKey: (e) {
          if (e.isAltPressed ||
              e.isControlPressed ||
              e.isShiftPressed ||
              e.isMetaPressed) return;
          if (widget.acceptEnter &&
              [
                LogicalKeyboardKey.enter.keyId,
                LogicalKeyboardKey.numpadEnter.keyId
              ].contains(e.logicalKey.keyId)) {
            Navigator.pop(context, true);
          } else if (widget.escAsNeutral != null &&
              LogicalKeyboardKey.escape.keyId == e.logicalKey.keyId) {
            Navigator.pop(context, widget.escAsNeutral! ? null : false);
          }
        },
        child: AlertDialog(
            title: Text(widget.title ?? "Confirmation"),
            content: Text(widget.content),
            actions: <Widget>[
              if (widget.hasNeutralButton)
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
              if (widget.hasNegativeButton)
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ]));
  }
}
