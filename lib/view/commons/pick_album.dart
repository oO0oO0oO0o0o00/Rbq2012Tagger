import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';

Directory? pick_album() {
  final file = DirectoryPicker()
    ..defaultFilterIndex = 0
    ..title = 'Select an album, meow~';

  return file.getDirectory();
}
