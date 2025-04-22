import 'package:flutter/material.dart';

/// Enum representing different color themes for the application.
enum ThemeColor {
  blue,
  gray,
  green,
  neutral,
  orange,
  red,
  rose,
  slate,
  stone,
  violet,
  yellow,
  zinc;

  Color get asColor {
    switch (this) {
      case ThemeColor.blue:
        return const Color(0xff2563eb);
      case ThemeColor.gray:
        return const Color(0xff111827);
      case ThemeColor.green:
        return const Color(0xff16a34a);
      case ThemeColor.neutral:
        return const Color(0xff171717);
      case ThemeColor.orange:
        return const Color(0xfff97316);
      case ThemeColor.red:
        return const Color(0xffdc2626);
      case ThemeColor.rose:
        return const Color(0xffe11d48);
      case ThemeColor.slate:
        return const Color(0xff0f172a);
      case ThemeColor.stone:
        return const Color(0xff1c1917);
      case ThemeColor.violet:
        return const Color(0xff7c3aed);
      case ThemeColor.yellow:
        return const Color(0xfffacc15);
      case ThemeColor.zinc:
        return const Color(0xff18181b);
    }
  }
}
