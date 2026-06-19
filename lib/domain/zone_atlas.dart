class TimeZoneCity {
  final String city;
  final String region;
  final double utcOffset;

  const TimeZoneCity(this.city, this.region, this.utcOffset);

  String get offsetLabel {
    final sign = utcOffset >= 0 ? '+' : '-';
    final abs = utcOffset.abs();
    final h = abs.floor();
    final m = ((abs - h) * 60).round();
    final mm = m.toString().padLeft(2, '0');
    return 'UTC$sign$h:$mm';
  }
}

class ZoneAtlas {
  static const List<TimeZoneCity> cities = [
    TimeZoneCity('Los Angeles', 'Americas', -8),
    TimeZoneCity('Chicago', 'Americas', -6),
    TimeZoneCity('New York', 'Americas', -5),
    TimeZoneCity('Sao Paulo', 'Americas', -3),
    TimeZoneCity('London', 'Europe', 0),
    TimeZoneCity('Paris', 'Europe', 1),
    TimeZoneCity('Berlin', 'Europe', 1),
    TimeZoneCity('Athens', 'Europe', 2),
    TimeZoneCity('Dubai', 'Middle East', 4),
    TimeZoneCity('Mumbai', 'Asia', 5.5),
    TimeZoneCity('Bangkok', 'Asia', 7),
    TimeZoneCity('Singapore', 'Asia', 8),
    TimeZoneCity('Hong Kong', 'Asia', 8),
    TimeZoneCity('Tokyo', 'Asia', 9),
    TimeZoneCity('Sydney', 'Oceania', 11),
    TimeZoneCity('Auckland', 'Oceania', 13),
  ];

  static TimeZoneCity byCity(String city) => cities.firstWhere(
        (c) => c.city == city,
        orElse: () => cities.firstWhere((c) => c.city == 'London'),
      );
}
