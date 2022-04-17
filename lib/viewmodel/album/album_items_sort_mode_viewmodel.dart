import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../model/model.dart';

class AlbumItemsSortModeViewModel {
  final String name;
  final Function(List<AlbumItem> items, bool reversed) sort;
  final IconData? icon;
  final bool reversed;
  static List<AlbumItemsSortModeViewModel>? _sortModes;

  AlbumItemsSortModeViewModel(this.name, this.sort, this.icon,
      {this.reversed = false});

  static List<AlbumItemsSortModeViewModel> get sortModes {
    return _sortModes ??= [
      AlbumItemsSortModeViewModel(
          "Alphabetic", AlbumSortModes.alphabetic, Icons.sort_by_alpha),
      AlbumItemsSortModeViewModel(
          "Zalphabetic", AlbumSortModes.alphabetic, null,
          reversed: true),
      AlbumItemsSortModeViewModel(
          "Newer First", AlbumSortModes.byDate, Icons.date_range,
          reversed: true),
      AlbumItemsSortModeViewModel("Older First", AlbumSortModes.byDate, null),
    ];
  }

  static AlbumItemsSortModeViewModel get defaultMode => sortModes[2];
}
