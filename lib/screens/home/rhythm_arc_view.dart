import 'package:flutter/material.dart';

import '../../domain/circadian_models.dart';
import '../../domain/hour_format.dart';
import '../../domain/phase_planner.dart';
import '../../domain/zone_atlas.dart';
import '../../state/journey_pulse.dart';
import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../../widgets/circadian_arc.dart';
import '../../widgets/dawn_card.dart';

class RhythmArcView extends StatefulWidget {
  const RhythmArcView({super.key});

  @override
  State<RhythmArcView> createState() => _RhythmArcViewState();
}

class _RhythmArcViewState extends State<RhythmArcView> {
  int _selectedOffset = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JourneySelection>(
      valueListenable: JourneyPulse.instance.selection,
      builder: (context, selection, _) {
        final origin = ZoneAtlas.byCity(selection.originCity);
        final destination = ZoneAtlas.byCity(selection.destinationCity);
        final plan = PhasePlanner.build(
          originOffset: origin.utcOffset,
          destinationOffset: destination.utcOffset,
        );

        final days = plan.days;
        final current = days.firstWhere(
          (d) => d.offset == _selectedOffset,
          orElse: () => days.firstWhere((d) => d.offset == 0,
              orElse: () => days.first),
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            _dayStrip(days, current),
            const SizedBox(height: 18),
            DawnCard(
              child: Column(
                children: [
                  Text(current.caption, style: DawnType.heading()),
                  const SizedBox(height: 6),
                  Text(
                    '${selection.originCity} → ${selection.destinationCity}',
                    style: DawnType.caption(),
                  ),
                  const SizedBox(height: 8),
                  CircadianArc(
                    bands: current.bands,
                    sunHour: PhasePlanner.sunHourFor(destination.utcOffset),
                    moonHour: PhasePlanner.moonHourFor(destination.utcOffset),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('06:00', style: DawnType.caption()),
                      Text('Noon', style: DawnType.caption()),
                      Text('18:00', style: DawnType.caption()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _legend(),
            const SizedBox(height: 18),
            Text('This day at a glance', style: DawnType.label()),
            const SizedBox(height: 12),
            _sleepRow(current),
            ...current.bands
                .where((b) => b.kind != BandKind.sleep)
                .map(_bandRow),
          ],
        );
      },
    );
  }

  Widget _dayStrip(List<CircadianDay> days, CircadianDay current) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final day = days[i];
          final selected = day.offset == current.offset;
          return GestureDetector(
            onTap: () => setState(() => _selectedOffset = day.offset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 86,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                gradient: selected ? DawnPalette.horizonGradient : null,
                color: selected ? null : DawnPalette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? Colors.transparent : DawnPalette.hairline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.offset == 0
                        ? 'Travel'
                        : day.offset < 0
                            ? '−${day.offset.abs()}'
                            : '+${day.offset}',
                    style: DawnType.clock(20,
                        color: selected ? Colors.white : DawnPalette.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'day',
                    style: DawnType.caption(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.9)
                            : DawnPalette.inkFaint),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _legend() {
    final items = [
      ('Seek light', DawnPalette.noon),
      ('Avoid light', DawnPalette.dusk),
      ('Sleep', DawnPalette.duskDeep),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((it) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: it.$2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(it.$1, style: DawnType.caption(color: DawnPalette.inkSoft)),
          ],
        );
      }).toList(),
    );
  }

  Widget _sleepRow(CircadianDay day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DawnCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.bedtime_rounded, color: DawnPalette.duskDeep),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sleep window', style: DawnType.bodyStrong()),
                  Text(
                    'Bed ${formatHour(day.bedtimeHour)} · wake ${formatHour(day.wakeHour)}',
                    style: DawnType.caption(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bandRow(DayBand band) {
    final tint = band.kind == BandKind.seekLight
        ? DawnPalette.noon
        : DawnPalette.dusk;
    final icon = band.kind == BandKind.seekLight
        ? Icons.wb_sunny_rounded
        : Icons.nightlight_round;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DawnCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: tint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(band.label, style: DawnType.bodyStrong()),
                  Text(
                    '${formatHour(band.fromHour)} – ${formatHour(band.toHour)}',
                    style: DawnType.caption(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
