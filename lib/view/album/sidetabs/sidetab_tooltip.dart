import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../../commons/app_tooltip_content.dart';

class SidetabTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  const SidetabTooltip({Key? key, required this.message, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      content: AppTooltipContent(message),
      preferredDirection: AxisDirection.right,
      waitDuration: const Duration(milliseconds: 200),
      child: child,
    );
  }
}
