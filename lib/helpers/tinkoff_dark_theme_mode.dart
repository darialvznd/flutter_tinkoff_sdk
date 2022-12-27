enum TinkoffDarkThemeMode { disabled, enabled, auto }

extension TinkoffDarkThemeModeHelper on TinkoffDarkThemeMode {
  String get value {
    switch (this) {
      case TinkoffDarkThemeMode.disabled:
        return "DISABLED";
      case TinkoffDarkThemeMode.enabled:
        return "ENABLED";
      case TinkoffDarkThemeMode.auto:
        return "AUTO";
    }
  }
}
