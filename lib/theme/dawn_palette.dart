import 'package:flutter/material.dart';

class DawnPalette {
  static const Color canvas = Color(0xFFFBF6F2);
  static const Color canvasDeep = Color(0xFFF1E8F0);
  static const Color hairline = Color(0xFFE7DCE6);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color ink = Color(0xFF2A2540);
  static const Color inkSoft = Color(0xFF6A6486);
  static const Color inkFaint = Color(0xFFA59FBC);

  static const Color dawn = Color(0xFFF6A582);
  static const Color dawnDeep = Color(0xFFEC7C5E);
  static const Color dawnWash = Color(0xFFFDE6DA);

  static const Color dusk = Color(0xFF6B5CC4);
  static const Color duskDeep = Color(0xFF4B3F9E);
  static const Color duskWash = Color(0xFFE6E1F7);

  static const Color noon = Color(0xFFF4C261);
  static const Color noonWash = Color(0xFFFBEFD2);

  static const Color rested = Color(0xFF59B89B);
  static const Color adjusting = Color(0xFFE2A24A);
  static const Color strained = Color(0xFFD9716A);

  static const LinearGradient skylineGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFCE0D2), Color(0xFFF3E7F4), Color(0xFFFBF6F2)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient horizonGradient = LinearGradient(
    colors: [dawn, dusk],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
