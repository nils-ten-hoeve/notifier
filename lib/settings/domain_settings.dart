class Settings {
  final DateTime workStart;
  final Duration workDuration;

  static const int lunchMinutes = 30;
  static const Duration defaultWorkDuration =
      Duration(hours: 7, minutes: 50 + lunchMinutes);

  const Settings({
    required this.workStart,
    this.workDuration = defaultWorkDuration,
  });

  Settings copyWith({
    DateTime? workStart,
    Duration? workDuration,
  }) =>
      Settings(
        workStart: workStart ?? this.workStart,
        workDuration: workDuration ?? this.workDuration,
      );

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.runtimeType == runtimeType &&
      other.workStart == workStart &&
      other.workDuration == workDuration;

  @override
  int get hashCode => Object.hash(workStart, workDuration);
}
