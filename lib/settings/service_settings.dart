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
    settings = _updateworkStartIfNeeded(settings);
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
    } catch (_) {
      return null;
    }
  }

  _defaultSettings() => Settings(workStart: nowMinus5Minutes);

  DateTime get nowMinus5Minutes =>
      DateTime.now().add(const Duration(minutes: 5));

  _updateworkStartIfNeeded(settings) => Settings(
      workStart: DateTime.now().copyWith(
          hour: 6,
          minute:
              58)); //TODO check if workStart is of today. if not use nowMinus5Minutes.
}
