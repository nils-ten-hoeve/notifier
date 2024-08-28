class Settings {
  final DateTime lastWorkStart;

  const Settings({required this.lastWorkStart});

  @override
  bool operator ==(Object other) =>
      other is Settings &&
      other.runtimeType == runtimeType &&
      other.lastWorkStart == lastWorkStart;

  @override
  int get hashCode => lastWorkStart.hashCode; //Object.hash(object1, object2);
}
