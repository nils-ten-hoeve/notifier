import 'dart:io';

import 'package:notifier/settings/data_settings_yaml_converter.dart';
import 'package:notifier/settings/domain_settings.dart';
import 'package:path_provider/path_provider.dart';

class SettingsDatabase {
  final String yamlFilePath;

  SettingsDatabase(this.yamlFilePath);

  Settings read() {
    var yaml = readFromYamlFile(yamlFilePath);
    var settings = settingsFromYaml(yaml);
    return settings;
  }

  write(Settings settings) {
    var yaml = settingsToYaml(settings);
    writeToYamlFile(yamlFilePath, yaml);
  }
}

Future<String> yamlFilePath() async {
  final Directory appSupportDir = await getApplicationSupportDirectory();
  var yamlFilePath =
      '${appSupportDir.path}${Platform.pathSeparator}notifier.yaml';
  return yamlFilePath;
}
