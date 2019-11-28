import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tododo/settings_bloc.dart';

enum Setting {
  CurrentTheme,
}

class SettingsService {
  SettingsService._(this.sharedPreferences, this.currentTheme);

  static Future<SettingsService> init() async {
    AppTheme currentTheme;
    var themeKey = EnumToString.parse(Setting.CurrentTheme);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey(themeKey)) {
      var value = sharedPreferences.getString(themeKey);
      currentTheme = EnumToString.fromString<AppTheme>(AppTheme.values, value);
    }

    return SettingsService._(sharedPreferences, currentTheme ?? AppTheme.Light);
  }

  AppTheme currentTheme;
  final SharedPreferences sharedPreferences;


  Future<bool> saveSetting<T>({
    @required Setting setting,
    @required T value,
  }) async {
    try {
      String key = EnumToString.parse(setting);

      switch (T) {
        case String:
          await sharedPreferences.setString(key, value as String);
          break;
        case int:
          await sharedPreferences.setInt(key, value as int);
          break;
        case bool:
          await sharedPreferences.setBool(key, value as bool);
          break;
        case double:
          await sharedPreferences.setDouble(key, value as double);
          break;
        case AppTheme:
          var themeKey = EnumToString.parse(Setting.CurrentTheme);
          var value = EnumToString.parse(currentTheme);
          sharedPreferences.setString(themeKey, value);
          break;
        default:
          throw Exception('Unknown type');
      }
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  Future<T> getSetting<T>({
    @required Setting setting,
  }) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String key = EnumToString.parse(setting);
      dynamic value;
      if (sharedPreferences.containsKey(key)) {
        value = await sharedPreferences.get(key);
      } else {
        return Future.value(null);
      }
      return Future.value(value is T ? value : null);
    } catch (e) {
      return Future.value(null);
    }
  }

  void switchTheme(AppTheme theme) async {
    currentTheme = theme;
    saveSetting<AppTheme>(setting: Setting.CurrentTheme, value: currentTheme);
  }
}
