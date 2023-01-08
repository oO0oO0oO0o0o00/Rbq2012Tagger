import 'package:flutter/material.dart';

class CheckboxRow extends StatelessWidget {
  final bool? value;
  final bool tristate;
  final Widget child;
  final void Function(bool? value) onChanged;

  const CheckboxRow({
    Key? key,
    this.value,
    required this.onChanged,
    required this.child,
    this.tristate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, tristate: tristate),
        Expanded(child: GestureDetector(onTap: () => onChanged(!(value ?? true)), child: child))
      ],
    );
  }
}
