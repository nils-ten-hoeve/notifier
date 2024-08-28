import 'dart:io';

import 'package:notifier/settings/domain_settings.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

Settings settingsFromYaml(Map<String, dynamic> yaml) => Settings(
      lastWorkStart: DateTime.parse(yaml['lastWorkStart'] as String),
      workDuration: Duration(minutes: yaml['workDuration']),
    );

Map<String, dynamic> settingsToYaml(Settings settings) => <String, dynamic>{
      'lastWorkStart': settings.lastWorkStart.toIso8601String(),
      'workDuration': settings.workDuration.inMinutes,
    };

Map<String, dynamic> readFromYamlFile(String yamlFilePath) {
  var yamlString = File(yamlFilePath).readAsStringSync();
  var yamlMap = loadYaml(yamlString) as YamlMap;
  return _convert(yamlMap);
}

Map<String, dynamic> _convert(YamlMap yamlMap) {
  var map = <String, dynamic>{};
  for (var key in yamlMap.keys) {
    if (key is String) {
      var value = yamlMap[key];
      if (value is YamlMap) {
        //recusive call
        value = _convert(value);
      }
      if (value is YamlList) {
        value = value.value;
      }
      map[key] = value;
    }
  }
  return map;
}

void writeToYamlFile(String yamlFilePath, Map<String, dynamic> yaml) {
  var yamlString = YamlWriter().write(yaml);
  if (yamlString == '{}') {
    yamlString = '';
  }
  File(yamlFilePath).writeAsStringSync(yamlString);
}
