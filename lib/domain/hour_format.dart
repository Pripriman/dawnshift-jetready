String formatHour(double hour) {
  final wrapped = ((hour % 24) + 24) % 24;
  final h = wrapped.floor();
  final m = ((wrapped - h) * 60).round();
  final hh = h.toString().padLeft(2, '0');
  final mm = m.toString().padLeft(2, '0');
  return '$hh:$mm';
}
