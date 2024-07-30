class Settings {
  final DateTime start;

  Settings({required this.start});
}

class SettingsService {
  Settings? _cachedSettings;

  Settings get settings {
    _cachedSettings ??= _readOrCreateSettings();
    return _cachedSettings!;
  }

  Settings? _readOrCreateSettings() {
    return Settings(start: DateTime.now().copyWith(hour: 7, minute: 30)); //TODO 
  }
}
