import 'package:flutter/material.dart';

/// A squared color preview like VS Code's.
class ColorSquare extends StatelessWidget {
  final Color color;

  const ColorSquare({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = Theme.of(context).iconTheme.size ?? 24;
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(border: Border.all(), color: color));
  }
}
