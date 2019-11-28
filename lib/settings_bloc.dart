import 'dart:async';

import 'package:tododo/settings_service.dart';

enum AppTheme {
  Light,
  Dark,
  Note,
}

class SettingsBloc {
  final _themeStreamController = StreamController<AppTheme>();
  final SettingsService _settingService;

  SettingsBloc(this._settingService);

  AppTheme get currentTheme => _settingService.currentTheme;
  Stream<AppTheme> get themeStream => _themeStreamController.stream;

  void dispose() {
    _themeStreamController.close();
  }

  void switchTheme(AppTheme theme) {
    _settingService.switchTheme(theme);
    _themeStreamController.sink.add(theme);
  }
}
