import 'dart:io';

/// Platform-related utilities.

bool isPC() => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
