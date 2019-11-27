import 'dart:async';

enum AppTheme {
  Light,
  Dark,
  Note,
}

class SettingsBloc {
  final _themeStreamController = StreamController<AppTheme>();

  AppTheme currentTheme = AppTheme.Light;
  Stream<AppTheme> get themeStream => _themeStreamController.stream;

  void dispose() {
    _themeStreamController.close();
  }

  void switchTheme(AppTheme theme) {
    currentTheme = theme;
    _themeStreamController.sink.add(theme);
  }
}
