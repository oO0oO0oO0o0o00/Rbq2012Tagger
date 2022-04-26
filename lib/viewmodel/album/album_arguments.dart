/// Argument of [AlbumPage] for navigation.
class AlbumArguments {
  final String path;
  final Function() onOpened;
  final Function() onFailure;

  AlbumArguments(
      {required this.path, required this.onOpened, required this.onFailure});
}
