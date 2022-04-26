import 'package:flutter/material.dart';

/// A tag-like view.
class TagView extends StatelessWidget {
  const TagView({
    Key? key,
    required this.child,
    required this.onTap,
    required this.backgroundColor,
  }) : super(key: key);
  final Function() onTap;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(18),
        color: backgroundColor,
        elevation: 4,
        child: InkWell(
            onTap: onTap,
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: child)));
  }
}
