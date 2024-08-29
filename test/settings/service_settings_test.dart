import 'package:flutter_test/flutter_test.dart';
import 'package:notifier/settings/service_settings.dart';

import 'package:shouldly/shouldly.dart';

void main() {
  group('SettingsService', () {
    var service = SettingsService();
    group('.isToday', () {
      test('if today it should return true', () {
        var result = service.isToday(DateTime.now());
        result.should.beTrue();
      });
      test('if yesterday it should return false', () {
        var result =
            service.isToday(DateTime.now().subtract(const Duration(days: 1)));
        result.should.beFalse();
      });
      test('if previous week it should return false', () {
        var result =
            service.isToday(DateTime.now().subtract(const Duration(days: 7)));
        result.should.beFalse();
      });
      test('if previous month it should return false', () {
        var result =
            service.isToday(DateTime.now().subtract(const Duration(days: 31)));
        result.should.beFalse();
      });
      test('if previous year it should return false', () {
        var result =
            service.isToday(DateTime.now().subtract(const Duration(days: 366)));
        result.should.beFalse();
      });
    });
  });
}
