import 'package:notifier/settings/domain_settings.dart';

class WorkTimeStatus {
  final String iconPath;
  final String message;

  factory WorkTimeStatus({
    required Settings settings,
    required DateTime now,
  }) {
    if (isWeekend(now)) {
      return WorkTimeStatus.weekend();
    }
    if (isInvalid(settings.workStart)) {
      return WorkTimeStatus.invalid();
    }
    var worked = now.difference(settings.workStart);
    var remaing = settings.workDuration - worked;
    if (isOverTime(remaing)) {
      return WorkTimeStatus.overtime(remaing * -1);
    }
    return WorkTimeStatus.remaining(remaing);
  }

  static bool isInvalid(DateTime start) =>
      start.hour < 5 || start.hour == 9 && start.minute > 0 || start.hour > 9;

  static bool isOverTime(Duration remaing) => remaing.isNegative;

  static bool isWeekend(DateTime now) => now.weekday >= 5;

  WorkTimeStatus.weekend()
      : iconPath = 'assets/weekend.ico',
        message = 'Weekend!';

  WorkTimeStatus.invalid()
      : iconPath = 'assets/invalid.ico',
        message = 'Invalid start time.';

  WorkTimeStatus.overtime(Duration duration)
      : iconPath = 'assets/overtime.ico',
        message = '${format(duration)} overtime.';

  WorkTimeStatus.remaining(Duration duration)
      : iconPath = duration.inMinutes <= 9
            ? 'assets/O${duration.inMinutes}.ico'
            : 'assets/${duration.inHours}${(duration.inMinutes % 60 ~/ 10)}.ico',
        message = '${format(duration)} remaining.';

  static String format(Duration duration) {
    if (duration.inMinutes == 1) {
      return '${duration.inMinutes} minute';
    }
    if (duration.inMinutes <= 59) {
      return '${duration.inMinutes} minutes';
    }
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    var hours = duration.inHours;
    var min = twoDigits(duration.inMinutes.remainder(60).abs());
    return "$hours:$min";
  }

  @override
  bool operator ==(Object other) {
    return other is WorkTimeStatus &&
        other.runtimeType == runtimeType &&
        other.iconPath == iconPath &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(iconPath, message);
}
