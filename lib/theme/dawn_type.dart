import 'package:flutter/material.dart';
import 'dawn_palette.dart';

class DawnType {
  static TextStyle _t(
    FontWeight weight,
    double size, {
    double? height,
    double? spacing,
    Color? color,
  }) {
    return TextStyle(
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: spacing,
      color: color ?? DawnPalette.ink,
    );
  }

  static TextStyle display({Color? color}) =>
      _t(FontWeight.w600, 31, height: 1.14, spacing: -0.4, color: color);
  static TextStyle title({Color? color}) =>
      _t(FontWeight.w600, 22, height: 1.22, spacing: -0.2, color: color);
  static TextStyle heading({Color? color}) =>
      _t(FontWeight.w600, 17, height: 1.28, color: color);
  static TextStyle body({Color? color}) =>
      _t(FontWeight.w400, 15, height: 1.5, color: color ?? DawnPalette.inkSoft);
  static TextStyle bodyStrong({Color? color}) =>
      _t(FontWeight.w600, 15, height: 1.46, color: color);
  static TextStyle label({Color? color}) =>
      _t(FontWeight.w600, 12.5, spacing: 0.6, color: color);
  static TextStyle caption({Color? color}) => _t(FontWeight.w500, 12,
      spacing: 0.2, color: color ?? DawnPalette.inkFaint);
  static TextStyle clock(double size, {Color? color, FontWeight? weight}) =>
      TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
        fontWeight: weight ?? FontWeight.w600,
        fontSize: size,
        height: 1.0,
        letterSpacing: 0.4,
        color: color ?? DawnPalette.ink,
      );
}
