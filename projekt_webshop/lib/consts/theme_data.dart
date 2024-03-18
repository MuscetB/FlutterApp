import 'package:flutter/material.dart';
import 'package:projekt_webshop/consts/app_colors.dart';

class Styles {
  static ThemeData themeData(
      {required bool isDarkTheme, required BuildContext context}) {
    //dva argumenta (isDarkTheme i context)
    return ThemeData(
      scaffoldBackgroundColor: isDarkTheme
          ? AppColors.darkScaffoldColor
          : AppColors.lightScaffoldColor,
      cardColor: isDarkTheme
          ? const Color.fromARGB(255, 13, 6, 37)
          : AppColors.lightCardColor,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          backgroundColor: isDarkTheme
              ? AppColors.darkScaffoldColor
              : AppColors.lightScaffoldColor,
          elevation: 0,
          titleTextStyle:
              TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.all(10),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 1,
            color: Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
