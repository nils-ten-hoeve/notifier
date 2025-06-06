import 'dart:async';

import 'package:notifier/get_it/get_it.dart';
import 'package:notifier/settings/service_settings.dart';
import 'package:notifier/status/domain_status.dart';
import 'package:system_tray/system_tray.dart';

class Updater {
  final systemTray = SystemTray();
  final settingsService = getIt<SettingsService>();
  late WorkTimeStatus status;
  late WorkTimeStatus previousStatus;
  late Timer timer;

  static final Updater _singleton = Updater._internal();

  factory Updater() {
    return _singleton;
  }

  Updater._internal();

  Future<void> init() async {
    timer = Timer.periodic(const Duration(minutes: 1), (_) async {
      await updateSystemTray();
    });
  }

  Future<void> updateSystemTray() async {
    previousStatus = status;
    status = WorkTimeStatus(
      settings: settingsService.settings,
      now: DateTime.now(),
    );
    //only update icon if needed
    var iconPath =
        status.iconPath == previousStatus.iconPath ? null : status.iconPath;
    await systemTray.setSystemTrayInfo(
        toolTip: status.message, iconPath: iconPath);
  }

  Future<void> initSystemTray() async {
    status = WorkTimeStatus(
      settings: settingsService.settings,
      now: DateTime.now(),
    );
    await systemTray.initSystemTray(
        iconPath: status.iconPath, title: 'Notifier', toolTip: status.message);
  }

  void dispose() {
    timer.cancel();
  }
}
