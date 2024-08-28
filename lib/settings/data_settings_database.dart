import 'dart:io';

import 'package:notifier/settings/data_settings_yaml_converter.dart';
import 'package:notifier/settings/domain_settings.dart';

class SettingsDatabase {
  Settings read() {
    var yaml = readFromYamlFile(yamlFilePath);
    var settings = settingsFromYaml(yaml);
    return settings;
  }

  write(Settings settings) {
    var yaml = settingsToYaml(settings);
    writeToYamlFile(yamlFilePath, yaml);
  }

  final String yamlFilePath = Platform.resolvedExecutable
      .replaceFirst(RegExp(r'\\(?:.(?!\\))+$'), '\\notifier.yaml');
}
