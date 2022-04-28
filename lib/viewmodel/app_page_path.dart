import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

part 'app_page_path.freezed.dart';

enum AppPageKinds { home, album, tagsMgmt }

const _appPageNames = {
  AppPageKinds.home: 'Get Started',
  AppPageKinds.tagsMgmt: 'Manage Tags',
};

@freezed
class AppPagePath with _$AppPagePath {
  const AppPagePath._();

  const factory AppPagePath({required AppPageKinds kind, String? path}) =
      _AppPagePath;

  String get displayName {
    final path = this.path;
    return path != null ? basename(path) : _appPageNames[kind]!;
  }
}
