import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../util/inputs.dart';

class DateTextField extends StatefulWidget {
  final String labelText;
  final ChangeNotifier eventSource;
  final void Function(DateTime? dateTime) uplink;
  final DateTime? Function() downlink;
  const DateTextField(
      {Key? key,
      required this.labelText,
      required this.eventSource,
      required this.downlink,
      required this.uplink})
      : super(key: key);

  @override
  State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
  late TextEditingController editTextController;
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    editTextController = TextEditingController();
    focusNode = FocusNode()
      ..addListener(() {
        if (!focusNode.hasFocus) onDateEntered();
      });
    widget.eventSource.addListener(onUpstreamEvent);
  }

  @override
  void dispose() {
    editTextController.dispose();
    focusNode.dispose();
    widget.eventSource.removeListener(onUpstreamEvent);
    super.dispose();
  }

  void onUpstreamEvent() =>
      editTextController.text = formatDate(widget.downlink());

  String formatDate(DateTime? date) =>
      date?.toIso8601String().split('T').first ?? "";

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(children: [
        Expanded(
          child: TextField(
              focusNode: focusNode,
              controller: editTextController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9-_/]")),
                FilteringTextInputFormatter.deny(RegExp("[_/]"),
                    replacementString: "-"),
                FilteringTextInputFormatter.deny(RegExp("(?<![^-])-")),
                FilteringTextInputFormatter.deny(
                    RegExp("(?<=[^-]+-[^-]+-[^-]+)-")),
                LengthLimitingTextInputFormatter(10)
              ],
              // onSubmitted: (text) => onDateEntered(),
              decoration: InputDecoration(
                  labelText: widget.labelText, hintText: "yyyy-mm-dd")),
        ),
      ]),
    );
  }

  void onDateEntered() {
    var text = editTextController.text;
    if (text.isEmpty) {
      widget.uplink(null);
      return;
    }
    String year, month, day;
    if (text.contains("-")) {
      var parts = text.split("-");
      year = parts[0];
      month = parts.length > 1 ? parts[1] : "0";
      day = parts.length > 2 ? parts[2] : "0";
    } else {
      if (text.length == 6) {
        text = int.parse(text.substring(0, 2)) > 70 ? "20" : "19" + text;
      } else if (text.length > 8) {
        text = text.substring(text.length - 8, text.length);
      } else {
        text = "20000101".substring(0, 8 - text.length) + text;
      }
      year = text.substring(0, 4);
      month = text.substring(4, 6);
      day = text.substring(6, 8);
    }
    var date = DateTime(parseOptionalInt(year) ?? 1,
        parseOptionalInt(month) ?? 1, parseOptionalInt(day) ?? 1);
    widget.uplink(date);
    editTextController.text = formatDate(date);
  }
}
