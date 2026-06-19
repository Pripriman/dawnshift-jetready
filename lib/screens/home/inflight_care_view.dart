import 'package:flutter/material.dart';

import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../../widgets/dawn_card.dart';

class InflightCareView extends StatefulWidget {
  const InflightCareView({super.key});

  @override
  State<InflightCareView> createState() => _InflightCareViewState();
}

class _InflightCareViewState extends State<InflightCareView> {
  double _flightHours = 8;

  int get _hydrationStops => (_flightHours / 1.5).ceil();
  int get _movementStops => (_flightHours / 2).floor().clamp(1, 12);
  int get _waterMl => (_flightHours * 250).round();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        DawnCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Flight length', style: DawnType.heading()),
              const SizedBox(height: 4),
              Text(
                'We pace your reminders to match how long you are in the air.',
                style: DawnType.body(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${_flightHours.toStringAsFixed(1)} h',
                      style: DawnType.clock(26, color: DawnPalette.duskDeep)),
                ],
              ),
              Slider(
                value: _flightHours,
                min: 1,
                max: 16,
                divisions: 30,
                activeColor: DawnPalette.dusk,
                inactiveColor: DawnPalette.duskWash,
                label: '${_flightHours.toStringAsFixed(1)} h',
                onChanged: (v) => setState(() => _flightHours = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _metricCard(Icons.water_drop_rounded, DawnPalette.dusk,
                  '$_waterMl ml', 'Water target'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(Icons.timer_outlined, DawnPalette.dawn,
                  '$_hydrationStops sips', 'Spaced evenly'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Hydration plan', style: DawnType.label()),
        const SizedBox(height: 12),
        _careCard(
          Icons.local_drink_rounded,
          DawnPalette.dusk,
          'Drink small, drink often',
          'Aim for about a cup of water roughly every 90 minutes — that is $_hydrationStops top-ups across this flight. Skip excess alcohol and caffeine, which deepen dehydration.',
        ),
        _careCard(
          Icons.no_drinks_outlined,
          DawnPalette.adjusting,
          'Ease off the dry air',
          'Cabin air is very dry. Keep a refillable bottle handy and add lip balm and a little moisturiser to stay comfortable.',
        ),
        const SizedBox(height: 18),
        Text('Movement plan', style: DawnType.label()),
        const SizedBox(height: 12),
        _careCard(
          Icons.directions_walk_rounded,
          DawnPalette.dawn,
          'Stand and stretch $_movementStops times',
          'Get up and walk the aisle about every two hours. Gentle calf raises and ankle circles in your seat help circulation between walks.',
        ),
        _careCard(
          Icons.self_improvement_rounded,
          DawnPalette.rested,
          'Loosen up against stiffness',
          'Roll your shoulders, stretch your neck and flex your feet to reduce swelling and the discomfort of long stretches without moving.',
        ),
        const SizedBox(height: 16),
        Text(
          'General comfort guidance only — not medical advice. If you have circulation or clotting risks, speak with a clinician before flying.',
          style: DawnType.caption(),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _metricCard(IconData icon, Color tint, String value, String label) {
    return DawnCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: tint),
          const SizedBox(height: 10),
          Text(value, style: DawnType.title()),
          Text(label, style: DawnType.caption()),
        ],
      ),
    );
  }

  Widget _careCard(
      IconData icon, Color tint, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DawnCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tint),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DawnType.bodyStrong()),
                  const SizedBox(height: 4),
                  Text(body, style: DawnType.body()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
