import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notifier/settings/data_settings_database.dart';
import 'package:notifier/settings/domain_settings.dart';

import 'package:shouldly/shouldly.dart';

void main() {
  group('SettingsDatabase', () {
    SettingsDatabase database = SettingsDatabase();
    group('.yamlFilePath', () {
      test('starts with path of executable', () {
        database.yamlFilePath.should.startWith(Platform.resolvedExecutable
            .replaceFirst(RegExp(r'\\(?:.(?!\\))+$'), ''));
      });
      test('ends with "\\notifier.yaml"', () {
        database.yamlFilePath.should.endWith('\\notifier.yaml');
      });
    });

    group('.write(settings)', () {
      test('should store a settings object in a correct yaml file', () {
        var workStart = DateTime.now();
        var workDuration = const Duration(minutes: 123);
        var settings =
            Settings(workStart: workStart, workDuration: workDuration);
        database.write(settings);
        var fileContents = File(database.yamlFilePath).readAsStringSync();
        fileContents.should.be("workStart: '${workStart.toIso8601String()}'\n"
            "workDuration: ${workDuration.inMinutes}\n");
      });
    });

    group('.read()', () {
      test('should return a correct settings object', () {
        var now = DateTime.now();
        var settings = Settings(workStart: now);
        database.write(settings);
        var result = database.read();
        result.should.be(settings);
      });
    });
  });
}
