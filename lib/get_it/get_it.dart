import 'package:get_it/get_it.dart';
import 'package:notifier/settings/data_settings_database.dart';
import 'package:notifier/settings/service_settings.dart';

final getIt = GetIt.instance;

void initGetIt() {
  getIt.registerSingleton<SettingsDatabase>(SettingsDatabase());
  getIt.registerSingleton<SettingsService>(SettingsService());
}
