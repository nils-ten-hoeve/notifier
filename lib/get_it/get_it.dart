import 'package:get_it/get_it.dart';
import 'package:notifier/settings/data_settings_database.dart';
import 'package:notifier/settings/service_settings.dart';

final getIt = GetIt.instance;

Future<void> initGetIt() async {
  var filePath=await yamlFilePath();
  getIt.registerSingleton<SettingsDatabase>(SettingsDatabase(filePath));
  getIt.registerSingleton<SettingsService>(SettingsService());
}
