import 'package:flutter/material.dart';

import '../../domain/hour_format.dart';
import '../../domain/zone_atlas.dart';
import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../../widgets/dawn_card.dart';

class LayoverPlannerView extends StatefulWidget {
  const LayoverPlannerView({super.key});

  @override
  State<LayoverPlannerView> createState() => _LayoverPlannerViewState();
}

class _LayoverPlannerViewState extends State<LayoverPlannerView> {
  String _homeCity = 'London';
  final List<String> _compareCities = ['New York', 'Tokyo', 'Dubai'];
  double _referenceHour = 14;
  double _layoverHours = 5;

  Future<void> _pickHome() async {
    final chosen = await _cityPicker();
    if (chosen != null) setState(() => _homeCity = chosen);
  }

  Future<void> _addCompare() async {
    final chosen = await _cityPicker();
    if (chosen != null && !_compareCities.contains(chosen)) {
      setState(() => _compareCities.add(chosen));
    }
  }

  Future<String?> _cityPicker() {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: DawnPalette.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) => DraggableScrollableSheet(
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
                Text('Pick a city', style: DawnType.title()),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    controller: controller,
                    children: ZoneAtlas.cities.map((c) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.city, style: DawnType.bodyStrong()),
                        subtitle: Text(c.region, style: DawnType.caption()),
                        trailing: Text(c.offsetLabel,
                            style: DawnType.clock(14,
                                color: DawnPalette.duskDeep)),
                        onTap: () => Navigator.pop(context, c.city),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = ZoneAtlas.byCity(_homeCity);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        DawnCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meeting planner', style: DawnType.heading()),
              const SizedBox(height: 4),
              Text(
                'Pick a time in your home city and see when it lands elsewhere — handy for calls without waking anyone.',
                style: DawnType.body(),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickHome,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: DawnPalette.canvas,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: DawnPalette.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.home_rounded,
                          color: DawnPalette.duskDeep, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Home: ${home.city} (${home.offsetLabel})',
                            style: DawnType.bodyStrong()),
                      ),
                      const Icon(Icons.expand_more_rounded,
                          color: DawnPalette.inkFaint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Reference time: ${formatHour(_referenceHour)}',
                  style: DawnType.label()),
              Slider(
                value: _referenceHour,
                min: 0,
                max: 23.5,
                divisions: 47,
                activeColor: DawnPalette.dawn,
                inactiveColor: DawnPalette.dawnWash,
                onChanged: (v) => setState(() => _referenceHour = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._compareCities.map((city) => _zoneRow(home, city)),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: _addCompare,
          style: OutlinedButton.styleFrom(
            foregroundColor: DawnPalette.duskDeep,
            side: const BorderSide(color: DawnPalette.hairline),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text('Add a city', style: DawnType.label()),
        ),
        const SizedBox(height: 24),
        DawnCard(
          color: DawnPalette.duskWash,
          border: Border.all(color: DawnPalette.dusk.withValues(alpha: 0.4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Layover guide', style: DawnType.heading()),
              const SizedBox(height: 4),
              Text('How long is your connection?',
                  style: DawnType.caption()),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _layoverHours,
                      min: 1,
                      max: 12,
                      divisions: 22,
                      activeColor: DawnPalette.dusk,
                      inactiveColor: Colors.white,
                      onChanged: (v) => setState(() => _layoverHours = v),
                    ),
                  ),
                  Text('${_layoverHours.toStringAsFixed(1)} h',
                      style: DawnType.clock(16, color: DawnPalette.duskDeep)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ..._layoverTips(),
      ],
    );
  }

  Widget _zoneRow(TimeZoneCity home, String city) {
    final target = ZoneAtlas.byCity(city);
    final diff = target.utcOffset - home.utcOffset;
    final localHour = _referenceHour + diff;
    final friendly = _comfort(localHour);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DawnCard(
        padding: const EdgeInsets.all(16),
        onTap: city == _homeCity
            ? null
            : () => setState(() => _compareCities.remove(city)),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: friendly.$2.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(friendly.$1, color: friendly.$2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(target.city, style: DawnType.bodyStrong()),
                  Text('${target.offsetLabel} · ${friendly.$3}',
                      style: DawnType.caption()),
                ],
              ),
            ),
            Text(formatHour(localHour),
                style: DawnType.clock(20, color: DawnPalette.ink)),
          ],
        ),
      ),
    );
  }

  (IconData, Color, String) _comfort(double hour) {
    final h = ((hour % 24) + 24) % 24;
    if (h >= 8 && h < 21) {
      return (Icons.wb_sunny_rounded, DawnPalette.rested, 'Good to call');
    }
    if (h >= 21 && h < 23) {
      return (Icons.bedtime_rounded, DawnPalette.adjusting, 'Getting late');
    }
    return (Icons.nightlight_round, DawnPalette.strained, 'Asleep — avoid');
  }

  List<Widget> _layoverTips() {
    final tips = <(IconData, Color, String, String)>[];
    if (_layoverHours < 2) {
      tips.add((
        Icons.directions_run_rounded,
        DawnPalette.dawn,
        'Keep it moving',
        'Short connection — walk briskly between gates, hydrate, and stretch rather than sitting down.',
      ));
    } else {
      tips.add((
        Icons.light_mode_rounded,
        DawnPalette.noon,
        'Step toward daylight',
        'With a few hours spare, find a bright window or step outside if you can — natural light helps reset your clock.',
      ));
      if (_layoverHours >= 4) {
        tips.add((
          Icons.airline_seat_flat_rounded,
          DawnPalette.dusk,
          'Consider a short nap',
          'A nap of 20–40 minutes can ease fatigue without making it harder to sleep later. Set an alarm so it stays short.',
        ));
      }
    }
    tips.add((
      Icons.restaurant_rounded,
      DawnPalette.rested,
      'Eat on the new schedule',
      'Time a light meal to the mealtime of your destination to nudge your body toward the new rhythm.',
    ));
    return tips.map((t) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DawnCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(t.$1, color: t.$2),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.$3, style: DawnType.bodyStrong()),
                    const SizedBox(height: 4),
                    Text(t.$4, style: DawnType.body()),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
