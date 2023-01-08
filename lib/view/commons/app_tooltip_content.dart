import 'package:flutter/material.dart';

class AppTooltipContent extends StatelessWidget {
  final String text;
  const AppTooltipContent(
    this.text, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), child: Text(text));
  }
}
