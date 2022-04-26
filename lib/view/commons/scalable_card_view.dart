import 'package:flutter/material.dart';

/// A scalable card view.
///
/// Matches parent when there is enough space,
/// wrap content and scrolls when there is not.
class ScalableCardView extends StatelessWidget {
  final List<Widget>? children;
  final List<Widget> Function(BoxConstraints constraint)? builder;

  const ScalableCardView({Key? key, this.children, this.builder})
      : assert(children != null || builder != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
              builder: (context, constraint) => SingleChildScrollView(
                  controller: ScrollController(),
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: children ?? builder!(constraint))))))));
}
