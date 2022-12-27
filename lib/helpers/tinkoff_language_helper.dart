enum TinkoffLanguage { ru, en }

extension TinkoffLanguageHelper on TinkoffLanguage {
  String get value {
    switch (this) {
      case TinkoffLanguage.ru:
        return "RU";
      case TinkoffLanguage.en:
        return "EN";
    }
  }
}
