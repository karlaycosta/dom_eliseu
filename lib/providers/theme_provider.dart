import 'package:flutter/material.dart';

final class ThemeProvider with ChangeNotifier {
  static final _instance = ThemeProvider._();
  static ThemeProvider get instance => _instance;
  ThemeProvider._();

  Color _color = Colors.blue;
  Color get color => _color;
  set color(Color color) {
    if (_color != color) {
      _color = color;
      notifyListeners();
    }
  }

  bool _isDark = false;
  bool get isDark => _isDark;
  set isDark(bool value) {
    if (_isDark != value) {
      _isDark = value;
      notifyListeners();
    }
  }
}