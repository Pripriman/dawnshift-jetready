import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:circadia/domain/circadian_models.dart';
import 'package:circadia/domain/phase_planner.dart';
import 'package:circadia/domain/zone_atlas.dart';
import 'package:circadia/widgets/circadian_arc.dart';

void main() {
  testWidgets('CircadianArc renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircadianArc(bands: [], sunHour: 13, moonHour: 1),
          ),
        ),
      ),
    );
    expect(find.byType(CircadianArc), findsOneWidget);
  });

  test('eastward flight advances the clock', () {
    final plan = PhasePlanner.build(
      originOffset: ZoneAtlas.byCity('London').utcOffset,
      destinationOffset: ZoneAtlas.byCity('Tokyo').utcOffset,
    );
    expect(plan.direction, ShiftDirection.eastward);
    expect(plan.zoneGap, 9);
    expect(plan.days.isNotEmpty, true);
  });

  test('westward flight delays the clock', () {
    final plan = PhasePlanner.build(
      originOffset: ZoneAtlas.byCity('London').utcOffset,
      destinationOffset: ZoneAtlas.byCity('New York').utcOffset,
    );
    expect(plan.direction, ShiftDirection.westward);
  });
}
