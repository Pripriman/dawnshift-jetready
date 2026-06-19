import 'package:flutter/foundation.dart';

class JourneySelection {
  final String originCity;
  final String destinationCity;
  final double departureHour;
  final double arrivalHour;

  const JourneySelection({
    required this.originCity,
    required this.destinationCity,
    required this.departureHour,
    required this.arrivalHour,
  });

  JourneySelection copyWith({
    String? originCity,
    String? destinationCity,
    double? departureHour,
    double? arrivalHour,
  }) {
    return JourneySelection(
      originCity: originCity ?? this.originCity,
      destinationCity: destinationCity ?? this.destinationCity,
      departureHour: departureHour ?? this.departureHour,
      arrivalHour: arrivalHour ?? this.arrivalHour,
    );
  }
}

class JourneyPulse {
  JourneyPulse._();
  static final JourneyPulse instance = JourneyPulse._();

  final ValueNotifier<JourneySelection> selection = ValueNotifier(
    const JourneySelection(
      originCity: 'London',
      destinationCity: 'Tokyo',
      departureHour: 11,
      arrivalHour: 7,
    ),
  );

  void update(JourneySelection next) => selection.value = next;
}
