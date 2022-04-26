import 'package:flutter/material.dart';

/// Background - foreground color pairs used for tags.
class ColorSpec {
  final String name;
  final Color background;
  final Color foreground;

  static final amber =
      ColorSpec("amber", background: Colors.amber, foreground: Colors.black);
  static final black =
      ColorSpec("black", background: Colors.black, foreground: Colors.white);
  static final blue =
      ColorSpec("blue", background: Colors.blue, foreground: Colors.black);
  static final blueGrey = ColorSpec("blueGrey",
      background: Colors.blueGrey, foreground: Colors.white);
  static final brown =
      ColorSpec("brown", background: Colors.brown, foreground: Colors.white);
  static final cyan =
      ColorSpec("cyan", background: Colors.cyan, foreground: Colors.black);
  static final deepOrange = ColorSpec("deepOrange",
      background: Colors.deepOrange, foreground: Colors.black);
  static final deepPurple = ColorSpec("deepPurple",
      background: Colors.deepPurple, foreground: Colors.black);
  static final green =
      ColorSpec("green", background: Colors.green, foreground: Colors.black);
  static final grey =
      ColorSpec("grey", background: Colors.grey, foreground: Colors.black);
  static final indigo =
      ColorSpec("indigo", background: Colors.indigo, foreground: Colors.black);
  static final lightBlue = ColorSpec("lightBlue",
      background: Colors.lightBlue, foreground: Colors.black);
  static final lightGreen = ColorSpec("lightGreen",
      background: Colors.lightGreen, foreground: Colors.black);
  static final lime =
      ColorSpec("lime", background: Colors.lime, foreground: Colors.black);
  static final orange =
      ColorSpec("orange", background: Colors.orange, foreground: Colors.black);
  static final pink =
      ColorSpec("pink", background: Colors.pink, foreground: Colors.black);
  static final purple =
      ColorSpec("purple", background: Colors.purple, foreground: Colors.white);
  static final red =
      ColorSpec("red", background: Colors.red, foreground: Colors.black);
  static final teal =
      ColorSpec("teal", background: Colors.teal, foreground: Colors.black);
  static final white =
      ColorSpec("white", background: Colors.white, foreground: Colors.black);
  static final yellow =
      ColorSpec("yellow", background: Colors.yellow, foreground: Colors.black);

  static Map<String, ColorSpec>? _mapping;

  ColorSpec(this.name, {required this.background, required this.foreground});

  static ColorSpec getWith({required String name}) {
    final mapping =
        _mapping ??= Map.fromEntries(all.map((e) => MapEntry(e.name, e)));
    return mapping[name]!;
  }

  static List<ColorSpec>? _all;

  static List<ColorSpec> get all => _all ??= [
        amber,
        black,
        blue,
        blueGrey,
        brown,
        cyan,
        deepOrange,
        deepPurple,
        green,
        grey,
        indigo,
        lightBlue,
        lightGreen,
        lime,
        orange,
        pink,
        purple,
        red,
        teal,
        white,
        yellow,
      ];
}
