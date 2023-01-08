import 'package:flutter/material.dart';
import 'package:tabbed_view/tabbed_view.dart';

/// Theme for [TabbedView] which is used for tabbing, mimicking VS Code's.
/// Based on [TabbedView]'s built-in`MobileTheme`. It's a pill of mess.
class TheTabbedViewTheme {
  static TabbedViewThemeData build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final fontSize = theme.textTheme.bodyText1?.fontSize ?? 16;
    Color foregroundColor = theme.hintColor;
    Color highlightedBgColor = _saturationBlend(primaryColor, .2);
    Color backgroundColor = _saturationBlend(primaryColor, .06);
    Color selectedTextColor = theme.textTheme.bodyText1?.color ?? Colors.black;
    Color selectedTabColor = _saturationBlend(primaryColor, .02);
    final tabColor = _saturationBlend(primaryColor, .1);
    return TabbedViewThemeData(
        tabsArea: tabsAreaTheme(
            highlightedBgColor: highlightedBgColor,
            foregroundColor: foregroundColor,
            fontSize: fontSize,
            backgroundColor: backgroundColor),
        tab: tabTheme(
            selectedTabColor: selectedTabColor,
            highlightedBgColor: highlightedBgColor,
            selectedTextColor: selectedTextColor,
            borderColor: backgroundColor,
            fontSize: fontSize,
            foregroundColor: foregroundColor,
            tabColor: tabColor),
        contentArea: contentAreaTheme(backgroundColor: backgroundColor, borderColor: backgroundColor),
        menu: menuTheme(
            hoverColor: highlightedBgColor,
            foregroundColor: foregroundColor,
            fontSize: fontSize,
            backgroundColor: backgroundColor));
  }

  static Color _saturationBlend(Color color, double saturation) =>
      HSVColor.fromColor(color).withSaturation(saturation).toColor();

  static TabsAreaThemeData tabsAreaTheme(
      {required Color highlightedBgColor,
      required double fontSize,
      required Color foregroundColor,
      required Color backgroundColor}) {
    return TabsAreaThemeData(
        equalHeights: EqualHeights.all,
        buttonIconSize: 24,
        normalButtonColor: foregroundColor,
        hoverButtonColor: foregroundColor,
        disabledButtonColor: Colors.transparent,
        buttonsAreaPadding: const EdgeInsets.all(12),
        hoverButtonBackground: BoxDecoration(color: highlightedBgColor),
        buttonPadding: const EdgeInsets.all(2),
        color: backgroundColor);
  }

  static TabThemeData tabTheme(
      {required Color tabColor,
      required Color selectedTabColor,
      required Color selectedTextColor,
      required Color highlightedBgColor,
      required double fontSize,
      required Color borderColor,
      required Color foregroundColor}) {
    BorderSide verticalBorderSide = BorderSide(color: borderColor, width: 1);
    Border border = Border(left: verticalBorderSide, right: verticalBorderSide);
    double borderHeight = 4;
    const vPadding = 12.0;
    return TabThemeData(
        // hide buttons by default, show on hover or selected
        normalButtonColor: Colors.transparent,
        hoverButtonColor: foregroundColor,
        textStyle: TextStyle(fontSize: fontSize, color: foregroundColor),
        buttonsOffset: 8,
        padding: const EdgeInsets.fromLTRB(24, vPadding, 8, vPadding),
        paddingWithoutButton: const EdgeInsets.fromLTRB(24, vPadding, 24, vPadding),
        hoverButtonBackground: BoxDecoration(color: highlightedBgColor, borderRadius: BorderRadius.circular(4)),
        buttonPadding: const EdgeInsets.all(4),
        buttonIconSize: 16,
        decoration: BoxDecoration(border: border, color: tabColor),
        innerBottomBorder: BorderSide(color: Colors.transparent, width: borderHeight),
        highlightedStatus: TabStatusThemeData(
          normalButtonColor: foregroundColor,
        ),
        selectedStatus: TabStatusThemeData(
            fontColor: selectedTextColor,
            normalButtonColor: foregroundColor,
            decoration: BoxDecoration(border: border, color: selectedTabColor)));
  }

  static ContentAreaThemeData contentAreaTheme({required Color borderColor, required Color backgroundColor}) {
    BorderSide borderSide = BorderSide(width: 1, color: borderColor);
    BoxBorder border = Border(bottom: borderSide, left: borderSide, right: borderSide);
    BoxDecoration decoration = BoxDecoration(color: backgroundColor, border: border);
    return ContentAreaThemeData(decoration: decoration);
  }

  static TabbedViewMenuThemeData menuTheme(
      {required Color backgroundColor,
      required double fontSize,
      required Color foregroundColor,
      required Color hoverColor}) {
    return TabbedViewMenuThemeData(
        textStyle: TextStyle(fontSize: fontSize, color: foregroundColor),
        margin: const EdgeInsets.all(8),
        menuItemPadding: const EdgeInsets.all(8),
        color: backgroundColor,
        hoverColor: hoverColor,
        dividerColor: backgroundColor,
        dividerThickness: 1);
  }
}
