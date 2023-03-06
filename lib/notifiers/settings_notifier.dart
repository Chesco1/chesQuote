import 'package:flutter/material.dart';

enum DisplayMode { normal, slideshow }

class SettingsNotifier extends ChangeNotifier {
  bool isDarkModeEnabled = false;
  DisplayMode mode = DisplayMode.normal;

  void setDisplayMode(DisplayMode newMode) {
    mode = newMode;
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkModeEnabled = !isDarkModeEnabled;
    notifyListeners();
  }
}
