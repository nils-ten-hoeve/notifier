import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:notifier/settings/domain_settings.dart';
import 'package:notifier/status/domain_status.dart';
import 'package:shouldly/shouldly.dart';

void main() {
  group('$WorkTimeStatus', () {
    group('Weekend!', () {
      test('start=on saterday', () {
        var start = DateTime.parse('2012-07-27 08:00:00');
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: start);
        status.message.should.be('Weekend!');
        status.iconPath.should.be('assets/weekend.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('start=on sunday', () {
        var start = DateTime.parse('2012-07-28 08:00:00');
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: start);
        status.message.should.be('Weekend!');
        status.iconPath.should.be('assets/weekend.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
    });

    group('Invalid start time.', () {
      test('start=before 5:00', () {
        var start = DateTime.parse('2012-07-25 04:59:00');
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: start);
        status.message.should.be('Invalid start time.');
        status.iconPath.should.be('assets/invalid.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('start=after 9:00', () {
        var start = DateTime.parse('2012-02-27 09:01:00');
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: start);
        status.message.should.be('Invalid start time.');
        status.iconPath.should.be('assets/invalid.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('start=at 10:00', () {
        var start = DateTime.parse('2012-02-27 10:00:00');
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: start);
        status.message.should.be('Invalid start time.');
        status.iconPath.should.be('assets/invalid.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
    });

    group('Remaining time', () {
      test('8:20 remaining.', () {
        var start = DateTime.parse('2012-02-27 08:00:00');
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: start);
        status.message.should.be('8:20 remaining.');
        status.iconPath.should.be('assets/82.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('7:20 remaining.', () {
        var start = DateTime.parse('2012-02-27 08:00:00');
        var now = start.add(const Duration(hours: 1));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('7:20 remaining.');
        status.iconPath.should.be('assets/72.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('1:00 remaining.', () {
        var start = DateTime.parse('2012-02-27 09:00:00');
        var now = start.add(const Duration(hours: 7, minutes: 20));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('1:00 remaining.');
        status.iconPath.should.be('assets/10.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('59 minutes remaining.', () {
        var start = DateTime.parse('2012-02-27 09:00:00');
        var now = start.add(const Duration(hours: 7, minutes: 21));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('59 minutes remaining.');
        status.iconPath.should.be('assets/05.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('10 minutes remaining.', () {
        var start = DateTime.parse('2012-02-27 09:00:00');
        var now = start.add(const Duration(hours: 8, minutes: 10));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('10 minutes remaining.');
        status.iconPath.should.be('assets/01.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('9 minutes remaining.', () {
        var start = DateTime.parse('2012-02-27 09:00:00');
        var now = start.add(const Duration(hours: 8, minutes: 11));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('9 minutes remaining.');
        status.iconPath.should.be('assets/O9.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('1 minute remaining.', () {
        var start = DateTime.parse('2012-02-27 09:00:00');
        var now = start.add(const Duration(hours: 8, minutes: 19));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('1 minute remaining.');
        status.iconPath.should.be('assets/O1.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('0 minutes remaining.', () {
        var start = DateTime.parse('2012-02-27 07:00:00');
        var now = start.add(const Duration(hours: 8, minutes: 20));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('0 minutes remaining.');
        status.iconPath.should.be('assets/O0.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
    });
    group('Overtime.', () {
      test('1 minute overtime.', () {
        var start = DateTime.parse('2012-02-27 07:00:00');
        var now = start
            .add(Settings.defaultWorkDuration + const Duration(minutes: 1));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('1 minute overtime.');
        status.iconPath.should.be('assets/overtime.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('9 minutes overtime.', () {
        var start = DateTime.parse('2012-02-27 07:00:00');
        var now = start
            .add(Settings.defaultWorkDuration + const Duration(minutes: 9));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('9 minutes overtime.');
        status.iconPath.should.be('assets/overtime.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('59 minutes overtime.', () {
        var start = DateTime.parse('2012-02-27 07:00:00');
        var now = start
            .add(Settings.defaultWorkDuration + const Duration(minutes: 59));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('59 minutes overtime.');
        status.iconPath.should.be('assets/overtime.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('1:00 overtime.', () {
        var start = DateTime.parse('2012-02-27 07:00:00');
        var now =
            start.add(Settings.defaultWorkDuration + const Duration(hours: 1));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('1:00 overtime.');
        status.iconPath.should.be('assets/overtime.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
      test('5:00 overtime.', () {
        var start = DateTime.parse('2012-02-27 07:00:00');
        var now =
            start.add(Settings.defaultWorkDuration + const Duration(hours: 5));
        var settings = Settings(workStart: start);
        var status = WorkTimeStatus(settings: settings, now: now);
        status.message.should.be('5:00 overtime.');
        status.iconPath.should.be('assets/overtime.ico');
        File(status.iconPath).existsSync().should.beTrue();
      });
    });
  });
}
