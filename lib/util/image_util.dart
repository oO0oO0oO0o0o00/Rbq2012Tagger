import 'package:path/path.dart' as pathlib;

const _pictureExtensions = [".png", ".jpg"];
bool isImageExtension(String path) => _pictureExtensions.contains(pathlib.extension(path));
