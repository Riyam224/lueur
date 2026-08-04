enum ThemeModeOption {
  light,
  dark,
  system;

  String get code => name;

  static ThemeModeOption fromCode(String? code) {
    return switch (code) {
      'light' => ThemeModeOption.light,
      'dark' => ThemeModeOption.dark,
      _ => ThemeModeOption.system,
    };
  }
}
