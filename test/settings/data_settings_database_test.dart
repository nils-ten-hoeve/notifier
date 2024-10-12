import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notifier/get_it/get_it.dart';
import 'package:notifier/settings/data_settings_database.dart';
import 'package:notifier/settings/domain_settings.dart';

import 'package:shouldly/shouldly.dart';

Future<void> main() async {
  group('SettingsDatabase', () {
    group('.yamlFilePath', () {
      test('starts with path of executable', () async {
        await initGetIt();
        SettingsDatabase database = getIt<SettingsDatabase>();
        database.yamlFilePath.should.startWith(Platform.resolvedExecutable
            .replaceFirst(RegExp(r'\\(?:.(?!\\))+$'), ''));
      });
      test('ends with "\\notifier.yaml"', () async {
        await initGetIt();
        SettingsDatabase database = getIt<SettingsDatabase>();
        database.yamlFilePath.should.endWith('\\notifier.yaml');
      });
    });

    group('.write(settings)', () {
      test('should store a settings object in a correct yaml file', () async {
        var workStart = DateTime.now();
        var workDuration = const Duration(minutes: 123);
        var settings =
            Settings(workStart: workStart, workDuration: workDuration);
        await initGetIt();
        SettingsDatabase database = getIt<SettingsDatabase>();
        database.write(settings);
        var fileContents = File(database.yamlFilePath).readAsStringSync();
        fileContents.should.be("workStart: '${workStart.toIso8601String()}'\n"
            "workDuration: ${workDuration.inMinutes}\n");
      });
    });

    group('.read()', () {
      test('should return a correct settings object', () async {
        var now = DateTime.now();
        var settings = Settings(workStart: now);
        await initGetIt();
        SettingsDatabase database = getIt<SettingsDatabase>();
        database.write(settings);
        var result = database.read();
        result.should.be(settings);
      });
    });
  });
}
