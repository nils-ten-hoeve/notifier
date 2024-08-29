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
    var workEnd = settings.workStart.add(settings.workDuration);
    var remaing = workEnd.difference(now);
    if (isOverTime(remaing)) {
      return WorkTimeStatus.overtime(
        settings.workStart,
        workEnd,
        remaing * -1,
      );
    }
    return WorkTimeStatus.remaining(
      settings.workStart,
      workEnd,
      remaing,
    );
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

  WorkTimeStatus.overtime(
    DateTime workStart,
    DateTime workEnd,
    Duration duration,
  )   : iconPath = 'assets/overtime.ico',
        message = '${formatDuration(duration)} overtime '
            '(${formatTime(workStart)}-${formatTime(workEnd)})';

  WorkTimeStatus.remaining(
    DateTime workStart,
    DateTime workEnd,
    Duration duration,
  )   : iconPath = duration.inMinutes <= 9
            ? 'assets/O${duration.inMinutes}.ico'
            : 'assets/${duration.inHours}${(duration.inMinutes % 60 ~/ 10)}.ico',
        message = '${formatDuration(duration)} remaining '
            '(${formatTime(workStart)}-${formatTime(workEnd)})';

  static String formatDuration(Duration duration) {
    if (duration.inMinutes == 1) {
      return '${duration.inMinutes} minute';
    }
    if (duration.inMinutes <= 59) {
      return '${duration.inMinutes} minutes';
    }

    var hours = duration.inHours;
    var min = twoDigits(duration.inMinutes.remainder(60).abs());
    return "$hours:$min";
  }

  static String formatTime(DateTime dateTime) =>
      '${dateTime.hour}:${twoDigits(dateTime.minute)}';

  static String twoDigits(int n) => n.toString().padLeft(2, "0");
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
