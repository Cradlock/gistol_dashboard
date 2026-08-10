
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsProvider extends ChangeNotifier {
  // Тема
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
    
  // Язык 
  static const Map<String,Map<String,String>> langDetails = {
    'en': {'name': 'ENGLISH', 'flag':'assets/translations/icons/en.png' },
    'ru': {'name': 'РУССКИЙ', 'flag':'assets/translations/icons/ru.png' },
    'ky': {'name': 'КЫРГЫЗЧА', 'flag':'assets/translations/icons/ky.png' },
  };


  Future<void> initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString("theme_mode");
    
    if(savedTheme == 'dark') _themeMode = ThemeMode.dark;
    if(savedTheme == 'light') _themeMode = ThemeMode.light;

    notifyListeners();
  }

  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme_mode", isOn ? 'dark' : 'light');

  }
    
  void changeLanguage(BuildContext context, Locale lang_code) {
    context.setLocale(lang_code);  
    notifyListeners();
  }
  
}



