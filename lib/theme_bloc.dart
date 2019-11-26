import 'dart:async';

enum AppTheme {
  Light,
  Dark,
  Note,
}

class ThemeBloc {
  final _themeController = StreamController<AppTheme>();

  AppTheme currentTheme = AppTheme.Light;
  Stream<AppTheme> get stream => _themeController.stream;

  void dispose() {
    _themeController.close();
  }

  void switchTheme(AppTheme theme) {
    currentTheme = theme;
    _themeController.sink.add(theme);
  }
}
