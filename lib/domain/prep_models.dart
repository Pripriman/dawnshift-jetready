class PrepItem {
  final String id;
  String title;
  bool packed;
  bool custom;

  PrepItem({
    required this.id,
    required this.title,
    this.packed = false,
    this.custom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'packed': packed,
        'custom': custom,
      };

  static PrepItem fromJson(Map<String, dynamic> j) => PrepItem(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        packed: j['packed'] as bool? ?? false,
        custom: j['custom'] as bool? ?? false,
      );
}

class ReadinessSignals {
  final bool sleepShiftStarted;
  final bool lightPlanFollowed;
  final bool hydrationOnTrack;
  final double packedFraction;

  const ReadinessSignals({
    required this.sleepShiftStarted,
    required this.lightPlanFollowed,
    required this.hydrationOnTrack,
    required this.packedFraction,
  });

  double get score {
    var total = 0.0;
    total += sleepShiftStarted ? 0.3 : 0.0;
    total += lightPlanFollowed ? 0.3 : 0.0;
    total += hydrationOnTrack ? 0.15 : 0.0;
    total += packedFraction * 0.25;
    return total.clamp(0, 1);
  }

  String get band {
    final s = score;
    if (s >= 0.75) return 'Rested';
    if (s >= 0.45) return 'Adjusting';
    return 'Strained';
  }
}
