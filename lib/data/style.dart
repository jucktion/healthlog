import 'package:flutter/material.dart';

final ThemeData healthTheme = ThemeData(
  primaryColor: Colors.black,
  splashColor: Colors.grey,
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
  ),
);
final ThemeData healthDark = ThemeData(
  primaryColor: Colors.white,
  splashColor: Colors.black87,
  primaryColorDark: Colors.black54,
  primaryTextTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black54,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    actionsIconTheme: IconThemeData(color: Colors.white),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  scaffoldBackgroundColor: Colors.black54,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: TextStyle(
        color: Colors.white,
      ),
    ),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.black87,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(color: Colors.white),
    labelStyle: TextStyle(color: Colors.white),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: TextStyle(color: Colors.white),
    // menuStyle: MenuStyle(
    //   backgroundColor: WidgetStatePropertyAll(Colors.black),
    // ),
  ),
  menuTheme: MenuBarThemeData(
      style: MenuStyle(backgroundColor: WidgetStatePropertyAll(Colors.grey))),
  textTheme: TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    displaySmall: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
    labelMedium: TextStyle(color: Colors.white),
    labelSmall: TextStyle(color: Colors.white),
    headlineLarge: TextStyle(color: Colors.white),
    headlineMedium: TextStyle(color: Colors.white),
    headlineSmall: TextStyle(color: Colors.white),
  ),
  listTileTheme: ListTileThemeData(
    titleTextStyle: TextStyle(color: Colors.white),
    subtitleTextStyle: TextStyle(color: Colors.white),
    tileColor: Colors.black54,
    leadingAndTrailingTextStyle: TextStyle(color: Colors.white),
  ),
  dialogBackgroundColor: Colors.black87,
);
