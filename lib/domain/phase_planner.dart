import 'circadian_models.dart';

class PhasePlanner {
  static double _wrap(double hour) => ((hour % 24) + 24) % 24;

  static CircadianPlan build({
    required double originOffset,
    required double destinationOffset,
    double baseBedtime = 23,
    double baseWake = 7,
  }) {
    final rawGap = destinationOffset - originOffset;
    final zoneGap = rawGap.round();

    ShiftDirection direction;
    if (zoneGap > 0) {
      direction = ShiftDirection.eastward;
    } else if (zoneGap < 0) {
      direction = ShiftDirection.westward;
    } else {
      direction = ShiftDirection.none;
    }

    final magnitude = zoneGap.abs();
    final perDay = direction == ShiftDirection.eastward ? 1.0 : 1.5;
    final shiftDays =
        magnitude == 0 ? 0 : (magnitude / perDay).ceil().clamp(1, 6);

    final days = <CircadianDay>[];
    final preDays = magnitude == 0 ? 0 : (shiftDays / 2).ceil().clamp(0, 3);

    for (var offset = -preDays; offset <= shiftDays; offset++) {
      final progressed = direction == ShiftDirection.eastward
          ? perDay * (offset + preDays)
          : -perDay * (offset + preDays);
      final clamped = direction == ShiftDirection.eastward
          ? progressed.clamp(0, magnitude.toDouble())
          : progressed.clamp(-magnitude.toDouble(), 0);

      final bed = _wrap(baseBedtime + clamped);
      final wake = _wrap(baseWake + clamped);

      days.add(CircadianDay(
        offset: offset,
        caption: _caption(offset),
        bedtimeHour: bed,
        wakeHour: wake,
        bands: _bands(direction, wake, bed),
      ));
    }

    return CircadianPlan(
      direction: direction,
      zoneGap: zoneGap,
      shiftDays: shiftDays,
      perDayShiftHours: perDay,
      days: days,
    );
  }

  static String _caption(int offset) {
    if (offset < 0) return 'Day ${offset.abs()} before';
    if (offset == 0) return 'Travel day';
    return 'Day $offset after';
  }

  static List<DayBand> _bands(
      ShiftDirection direction, double wake, double bed) {
    final sleepFrom = bed;
    final sleepTo = wake < bed ? wake + 24 : wake;

    final sleep = DayBand(
      kind: BandKind.sleep,
      fromHour: sleepFrom,
      toHour: sleepTo > 24 ? 24 : sleepTo,
      label: 'Sleep window',
    );

    final List<DayBand> seek;
    final List<DayBand> avoid;

    if (direction == ShiftDirection.eastward) {
      seek = [
        DayBand(
          kind: BandKind.seekLight,
          fromHour: _clampDay(wake),
          toHour: _clampDay(wake + 4),
          label: 'Seek bright light',
        ),
      ];
      avoid = [
        DayBand(
          kind: BandKind.avoidLight,
          fromHour: _clampDay(bed - 3),
          toHour: _clampDay(bed),
          label: 'Dim the lights',
        ),
      ];
    } else if (direction == ShiftDirection.westward) {
      seek = [
        DayBand(
          kind: BandKind.seekLight,
          fromHour: _clampDay(bed - 4),
          toHour: _clampDay(bed - 1),
          label: 'Seek evening light',
        ),
      ];
      avoid = [
        DayBand(
          kind: BandKind.avoidLight,
          fromHour: _clampDay(wake - 1),
          toHour: _clampDay(wake + 2),
          label: 'Ease into morning light',
        ),
      ];
    } else {
      seek = [
        DayBand(
          kind: BandKind.seekLight,
          fromHour: _clampDay(wake),
          toHour: _clampDay(wake + 3),
          label: 'Morning daylight',
        ),
      ];
      avoid = const [];
    }

    return [sleep, ...seek, ...avoid];
  }

  static double _clampDay(double hour) {
    final w = _wrap(hour);
    return w.clamp(0, 24).toDouble();
  }

  static double sunHourFor(double destinationOffset) => 13;
  static double moonHourFor(double destinationOffset) => 1;
}
