import 'package:notifier/settings/data_settings_database.dart';
import 'package:notifier/get_it/get_it.dart';
import 'package:notifier/settings/domain_settings.dart';

class SettingsService {
  Settings? _cachedSettings;

  Settings get settings {
    _cachedSettings ??= _initSettings();
    return _cachedSettings!;
  }

  Settings _initSettings() {
    var settings = _settingsFromDatabase() ?? _defaultSettings();
    settings = _updateLastWorkStartIfNeeded(settings);
    try {
      getIt<SettingsDatabase>().write(settings);
    } on Exception {
      // failed writing to the database: not the end of the world
    }
    return settings;
  }

  Settings? _settingsFromDatabase() {
    try {
      var database = getIt<SettingsDatabase>();
      return database.read();
    } on Exception {
      return null;
    }
  }

  _defaultSettings() => Settings(
      lastWorkStart: DateTime.now()
          .copyWith(hour: 7, minute: 12)); //TODO remove copyWith call

  _updateLastWorkStartIfNeeded(settings) =>
      settings; //TODO check if lastWorkStart is of today. if not use DateTimeNow.
}
