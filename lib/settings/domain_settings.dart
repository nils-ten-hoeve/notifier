class Settings {
  final DateTime lastWorkStart;
  final Duration workDuration;

  static const int lunchMinutes = 30;
  static const Duration defaultWorkDuration =
      Duration(hours: 7, minutes: 50 + lunchMinutes);

  const Settings({
    required this.lastWorkStart,
    this.workDuration = defaultWorkDuration,
  });

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.runtimeType == runtimeType &&
      other.lastWorkStart == lastWorkStart &&
      other.workDuration == workDuration;

  @override
  int get hashCode => Object.hash(lastWorkStart, workDuration);
}
