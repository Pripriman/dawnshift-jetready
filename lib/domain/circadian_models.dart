enum ShiftDirection { eastward, westward, none }

enum BandKind { seekLight, avoidLight, sleep, move }

class DayBand {
  final BandKind kind;
  final double fromHour;
  final double toHour;
  final String label;

  const DayBand({
    required this.kind,
    required this.fromHour,
    required this.toHour,
    required this.label,
  });
}

class CircadianDay {
  final int offset;
  final String caption;
  final List<DayBand> bands;
  final double bedtimeHour;
  final double wakeHour;

  const CircadianDay({
    required this.offset,
    required this.caption,
    required this.bands,
    required this.bedtimeHour,
    required this.wakeHour,
  });
}

class CircadianPlan {
  final ShiftDirection direction;
  final int zoneGap;
  final int shiftDays;
  final double perDayShiftHours;
  final List<CircadianDay> days;

  const CircadianPlan({
    required this.direction,
    required this.zoneGap,
    required this.shiftDays,
    required this.perDayShiftHours,
    required this.days,
  });

  String get directionLabel {
    switch (direction) {
      case ShiftDirection.eastward:
        return 'Eastward — advance your clock';
      case ShiftDirection.westward:
        return 'Westward — delay your clock';
      case ShiftDirection.none:
        return 'Same zone — minimal shift';
    }
  }
}
