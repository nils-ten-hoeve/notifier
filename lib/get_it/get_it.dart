import 'package:get_it/get_it.dart';
import 'package:notifier/settings/settings.data.dart';
import 'package:notifier/settings/settings.service.dart';

final getIt = GetIt.instance;

void initGetIt() {
  getIt.registerSingleton<SettingsDatabase>(SettingsDatabase());
  getIt.registerSingleton<SettingsService>(SettingsService());
}