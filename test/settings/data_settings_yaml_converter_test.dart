import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notifier/settings/data_settings_database.dart';
import 'package:notifier/settings/data_settings_yaml_converter.dart';
import 'package:notifier/settings/domain_settings.dart';

import 'package:shouldly/shouldly.dart';

void main() {
  group('given a yaml file path', () {
    var yamlFilePath = SettingsDatabase().yamlFilePath;
    group('writeToYamlFile function', () {
      test('writing a yaml, should return an correct yaml file', () {
        var yaml = {
          'name': 'Joe',
          'ids': [10, 20, 30],
          'desc': 'This is\na multiline\ntext',
          'enabled': true,
        };
        writeToYamlFile(yamlFilePath, yaml);
        var fileContents = File(yamlFilePath).readAsStringSync();
        fileContents.should.be("""
name: 'Joe'
ids: 
  - 10
  - 20
  - 30
desc: |-
  This is
  a multiline
  text
enabled: true
""");
      });
    });
    group('writeToYamlFile function', () {
      test('reading a yaml, should return an correct yaml', () {
        var yaml = {
          'name': 'Joe',
          'ids': [10, 20, 30],
          'desc': 'This is\na multiline\ntext',
          'enabled': true,
        };
        writeToYamlFile(yamlFilePath, yaml);
        var result = readFromYamlFile(yamlFilePath);
        result.should.be(yaml);
      });
    });

    group('settingsToYaml function', () {
      test('given a settings object, should return an correct yaml', () {
        var lastWorkStart = DateTime.now();
        var workDuration = const Duration(minutes: 321);
        var settings = Settings(
          lastWorkStart: lastWorkStart,
          workDuration: workDuration,
        );
        var yaml = settingsToYaml(settings);
        yaml.should.be({
          'lastWorkStart': lastWorkStart.toIso8601String(),
          'workDuration': workDuration.inMinutes,
        });
      });
    });

    group('settingsFromYaml function', () {
      test('given a settings yaml, should return an correct settings object',
          () {
        var lastWorkStart = DateTime.now();
        var workDuration = const Duration(minutes: 456);
        var yaml = {
          'lastWorkStart': lastWorkStart.toIso8601String(),
          'workDuration': workDuration.inMinutes,
        };
        var settings = settingsFromYaml(yaml);
        var expected =
            Settings(lastWorkStart: lastWorkStart, workDuration: workDuration);
        settings.should.be(expected);
      });
    });
  });
}
