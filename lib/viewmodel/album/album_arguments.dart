import 'package:flutter/widgets.dart';

/// Argument of [AlbumPage] for navigation.
class AlbumArguments {
  final String path;
  final void Function() onOpened;
  final void Function(BuildContext context) onFailure;

  AlbumArguments(
      {required this.path, required this.onOpened, required this.onFailure});
}
