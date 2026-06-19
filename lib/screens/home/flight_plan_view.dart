import 'package:flutter/material.dart';

import '../../domain/circadian_models.dart';
import '../../domain/hour_format.dart';
import '../../domain/phase_planner.dart';
import '../../domain/zone_atlas.dart';
import '../../state/journey_pulse.dart';
import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../../widgets/dawn_card.dart';

class FlightPlanView extends StatefulWidget {
  const FlightPlanView({super.key});

  @override
  State<FlightPlanView> createState() => _FlightPlanViewState();
}

class _FlightPlanViewState extends State<FlightPlanView> {
  late JourneySelection _selection;

  @override
  void initState() {
    super.initState();
    _selection = JourneyPulse.instance.selection.value;
  }

  void _apply(JourneySelection next) {
    setState(() => _selection = next);
    JourneyPulse.instance.update(next);
  }

  Future<void> _pickCity(bool origin) async {
    final chosen = await showModalBottomSheet<TimeZoneCity>(
      context: context,
      backgroundColor: DawnPalette.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => const _ZoneSheet(),
    );
    if (chosen == null) return;
    _apply(origin
        ? _selection.copyWith(originCity: chosen.city)
        : _selection.copyWith(destinationCity: chosen.city));
  }

  Future<void> _pickTime(bool departure) async {
    final base = departure ? _selection.departureHour : _selection.arrivalHour;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: base.floor(), minute: ((base - base.floor()) * 60).round()),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: DawnPalette.duskDeep,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final value = picked.hour + picked.minute / 60.0;
    _apply(departure
        ? _selection.copyWith(departureHour: value)
        : _selection.copyWith(arrivalHour: value));
  }

  @override
  Widget build(BuildContext context) {
    final origin = ZoneAtlas.byCity(_selection.originCity);
    final destination = ZoneAtlas.byCity(_selection.destinationCity);
    final plan = PhasePlanner.build(
      originOffset: origin.utcOffset,
      destinationOffset: destination.utcOffset,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        DawnCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your flight', style: DawnType.heading()),
              const SizedBox(height: 14),
              _routeRow(origin, destination),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _timeTile('Departure', _selection.departureHour,
                        () => _pickTime(true)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _timeTile('Arrival', _selection.arrivalHour,
                        () => _pickTime(false)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _directionCard(plan),
        const SizedBox(height: 18),
        Text('Light & sleep windows', style: DawnType.label()),
        const SizedBox(height: 12),
        ..._windowCards(plan),
        const SizedBox(height: 18),
        _melatoninNote(),
        const SizedBox(height: 14),
        _disclaimer(),
      ],
    );
  }

  Widget _routeRow(TimeZoneCity origin, TimeZoneCity destination) {
    return Row(
      children: [
        Expanded(child: _cityTile('From', origin, () => _pickCity(true))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward_rounded,
              color: DawnPalette.inkFaint, size: 20),
        ),
        Expanded(
            child: _cityTile('To', destination, () => _pickCity(false))),
      ],
    );
  }

  Widget _cityTile(String label, TimeZoneCity city, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: DawnPalette.canvas,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DawnPalette.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: DawnType.caption()),
            const SizedBox(height: 4),
            Text(city.city,
                style: DawnType.bodyStrong(), overflow: TextOverflow.ellipsis),
            Text(city.offsetLabel, style: DawnType.caption()),
          ],
        ),
      ),
    );
  }

  Widget _timeTile(String label, double hour, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: DawnPalette.canvas,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DawnPalette.hairline),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule_rounded,
                size: 18, color: DawnPalette.duskDeep),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DawnType.caption()),
                Text(formatHour(hour), style: DawnType.clock(17)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _directionCard(CircadianPlan plan) {
    final tint = plan.direction == ShiftDirection.eastward
        ? DawnPalette.dusk
        : plan.direction == ShiftDirection.westward
            ? DawnPalette.dawn
            : DawnPalette.rested;
    return DawnCard(
      color: DawnPalette.duskWash,
      border: Border.all(color: DawnPalette.dusk.withValues(alpha: 0.4)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(
              plan.direction == ShiftDirection.eastward
                  ? Icons.east_rounded
                  : plan.direction == ShiftDirection.westward
                      ? Icons.west_rounded
                      : Icons.adjust_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.directionLabel, style: DawnType.bodyStrong()),
                const SizedBox(height: 4),
                Text(
                  plan.zoneGap == 0
                      ? 'No meaningful time difference to adjust for.'
                      : '${plan.zoneGap.abs()} h difference · ease in over ${plan.shiftDays} day(s), about ${plan.perDayShiftHours.toStringAsFixed(1)} h per day.',
                  style: DawnType.caption(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _windowCards(CircadianPlan plan) {
    final travelDay = plan.days.firstWhere(
      (d) => d.offset == 0,
      orElse: () => plan.days.first,
    );
    return travelDay.bands.map((band) {
      final info = _bandInfo(band.kind);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DawnCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: info.$2.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(info.$1, color: info.$2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(band.label, style: DawnType.bodyStrong()),
                    const SizedBox(height: 2),
                    Text(
                      '${formatHour(band.fromHour)} – ${formatHour(band.toHour)} local',
                      style: DawnType.caption(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  (IconData, Color) _bandInfo(BandKind kind) {
    switch (kind) {
      case BandKind.seekLight:
        return (Icons.wb_sunny_rounded, DawnPalette.noon);
      case BandKind.avoidLight:
        return (Icons.nightlight_round, DawnPalette.dusk);
      case BandKind.sleep:
        return (Icons.bedtime_rounded, DawnPalette.duskDeep);
      case BandKind.move:
        return (Icons.directions_walk_rounded, DawnPalette.dawn);
    }
  }

  Widget _melatoninNote() {
    return DawnCard(
      color: DawnPalette.noonWash,
      border: Border.all(color: DawnPalette.noon.withValues(alpha: 0.5)),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: DawnPalette.adjusting),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'For reference only: melatonin timing is often discussed for eastward travel in the early evening. This is general education, not a dosage or medical recommendation.',
              style: DawnType.caption(color: DawnPalette.ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() => Text(
        'This companion is for education and organisation only and is not medical advice. For health concerns, consult a qualified professional.',
        style: DawnType.caption(),
        textAlign: TextAlign.center,
      );
}

class _ZoneSheet extends StatelessWidget {
  const _ZoneSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: DawnPalette.hairline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Choose a city', style: DawnType.title()),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: ZoneAtlas.cities.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: DawnPalette.hairline),
                  itemBuilder: (context, i) {
                    final city = ZoneAtlas.cities[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(city.city, style: DawnType.bodyStrong()),
                      subtitle:
                          Text(city.region, style: DawnType.caption()),
                      trailing: Text(city.offsetLabel,
                          style: DawnType.clock(14,
                              color: DawnPalette.duskDeep)),
                      onTap: () => Navigator.pop(context, city),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
