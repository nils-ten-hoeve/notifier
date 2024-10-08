import 'package:notifier/settings/data_settings_database.dart';
import 'package:notifier/get_it/get_it.dart';
import 'package:notifier/settings/domain_settings.dart';
import 'package:notifier/updater.dart';

class SettingsService {
  late Settings _cachedSettings;

  SettingsService._privateConstructor() {
    _initSettings();
  }

  /// SettingsService is a singleton to ensure
  /// we have only onve version of the [_cachedSettings]
  static final SettingsService _singleton =
      SettingsService._privateConstructor();

  factory SettingsService() => _singleton;

  Settings get settings => _cachedSettings;

  set settings(Settings settings) {
    _writeToDatabase(settings);
    _cachedSettings = settings;
    Updater().updateSystemTray();
  }

  void _initSettings() {
    _cachedSettings = _readFromDatabase() ?? _defaultSettings();
    _cachedSettings = _updateWorkStartIfNeeded(_cachedSettings);
    _writeToDatabase(settings);
    // no Updater().updateSystemTray();, because it is not initialized in time and will be called later
  }

  void _writeToDatabase(Settings settings) {
    try {
      getIt<SettingsDatabase>().write(settings);
    } on Exception {
      // failed writing to the database: not the end of the world
    }
  }

  Settings? _readFromDatabase() {
    try {
      var database = getIt<SettingsDatabase>();
      return database.read();
    } catch (_) {
      return null;
    }
  }

  Settings _defaultSettings() => Settings(workStart: nowMinus5Minutes);

  DateTime get nowMinus5Minutes =>
      DateTime.now().add(const Duration(minutes: -5));

  Settings _updateWorkStartIfNeeded(settings) {
    if (isToday(settings.workStart)) {
      return settings;
    }
    return Settings(workStart: nowMinus5Minutes);
  }

  bool isToday(DateTime dateTime) {
    var now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }
}
