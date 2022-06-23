// Packages
import 'package:flutter/material.dart';

ThemeData cinebaseTheme() {
  final ThemeData base = ThemeData(
    primarySwatch: Colors.pink,
    brightness: Brightness.dark,
    primaryColor: Colors.pink[400],
    fontFamily: 'Montserrat',
  );

  return base.copyWith(
    buttonTheme: _buildDefaultButtonTheme(base.buttonTheme),
    textTheme: _buildDefaultTextTheme(base.textTheme),
    primaryTextTheme: _buildDefaultTextTheme(base.primaryTextTheme),
  );
}

ButtonThemeData _buildDefaultButtonTheme(ButtonThemeData base) {
  return base.copyWith(
    buttonColor: Colors.pink,
    disabledColor: Colors.pink[200],
    layoutBehavior: ButtonBarLayoutBehavior.constrained,
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}

TextTheme _buildDefaultTextTheme(TextTheme base) {
  return base.copyWith(
    headline1: base.headline1?.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 20,
    ),
    subtitle1: base.subtitle1?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    ),
    bodyText1: base.bodyText1?.copyWith(
      fontSize: 14,
    ),
    caption: base.caption?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
  );
}
