import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const TTHEME_STATUS = "TTHEME_STATUS";
  bool _darkTheme = false;
  bool get getIsDarkTheme =>
      _darkTheme; //getIsDarkTheme - provjerava koja je tema postavljena

  ThemeProvider() {
    //getTheme metodu pozivamo istog trena kada se aplikacija pokrene
    getTheme();
  }
  setDarkTheme({required bool themeValue}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(TTHEME_STATUS, themeValue);
    _darkTheme =
        themeValue; //ova funkcija updatea vrijednost tj. postavljenu temu
    notifyListeners(); //funkciju koristimo kako bi obavijestili aplikaciju da se nešto promijenilo
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _darkTheme = prefs.getBool(TTHEME_STATUS) ??
        false; //u ovu metodu spremamo zadnju postavljenu temu
    notifyListeners();
    return _darkTheme;
  }
}
