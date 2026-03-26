import 'package:flutter/material.dart';
import 'package:flutter_gemini/hive/boxes.dart';
import 'package:flutter_gemini/hive/settings.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _shouldSpeak = false;

  bool get isDarkMode => _isDarkMode;

  bool get shouldSpeak => _shouldSpeak;

  //get the saved settings from box
  void getSavedSettings() {
    final settingsBox = Boxes.getSettings();

    //check is the settings box is open
    if (settingsBox.isNotEmpty) {
      //get the settings
      final settings = settingsBox.getAt(0);
      _isDarkMode = settings!.isDarkTheme;
      _shouldSpeak = settings.shouldSpeak;
    }
  }

  //toggle the dark mode
  void toggleDarkMode({required bool value}) {
    // Get the settings Box
    final settingsBox = Boxes.getSettings();
    
    if (settingsBox.isNotEmpty) {
      // Get the current settings
      final settings = settingsBox.getAt(0);
      // Update the settings
      settings!.isDarkTheme = value;
      settings.save();
    } else {
      // Save the new settings
      settingsBox.put(0, Settings(isDarkTheme: value, shouldSpeak: _shouldSpeak));
    }

    _isDarkMode = value;
    notifyListeners();
  }

  // Toggle the speak
  void toggleSpeak({required bool value}) {
    // Get the settings Box
    final settingsBox = Boxes.getSettings();

    if (settingsBox.isNotEmpty) {
      // Get the current settings
      final settings = settingsBox.getAt(0);
      // Update the settings
      settings!.shouldSpeak = value;
      settings.save();
    } else {
      // Save the new settings
      settingsBox.put(0, Settings(isDarkTheme: _isDarkMode, shouldSpeak: value));
    }

    _shouldSpeak = value;
    notifyListeners();
  }
}
