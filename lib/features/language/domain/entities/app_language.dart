enum AppLanguage {
  en,
  ar;

  String get code => name;

  static AppLanguage fromCode(String? code) {
    return switch (code) {
      'ar' => AppLanguage.ar,
      _ => AppLanguage.en,
    };
  }
}
