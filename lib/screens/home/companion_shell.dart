import 'package:flutter/material.dart';

import '../../runtime/circadian_bridge.dart';
import '../../runtime/pulse_relay.dart';
import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../access/access_deck.dart';
import 'flight_plan_view.dart';
import 'inflight_care_view.dart';
import 'layover_planner_view.dart';
import 'prep_checklist_view.dart';
import 'rhythm_arc_view.dart';

class CompanionShell extends StatefulWidget {
  const CompanionShell({super.key});

  @override
  State<CompanionShell> createState() => _CompanionShellState();
}

class _CompanionShellState extends State<CompanionShell> {
  int _tab = 0;

  static const _titles = [
    'Flight plan',
    'Daily rhythm',
    'In-flight care',
    'Layover & zones',
    'Prep & readiness',
  ];

  void _openProfile() {
    final enrolled = CircadianBridge.enrolled;
    showModalBottomSheet(
      context: context,
      backgroundColor: DawnPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile', style: DawnType.heading()),
                const SizedBox(height: 6),
                Text(
                  enrolled
                      ? (CircadianBridge.traveler?.email ?? 'Signed in')
                      : 'You are travelling as a guest.',
                  style: DawnType.body(),
                ),
                const SizedBox(height: 16),
                if (enrolled)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded,
                        color: DawnPalette.dawnDeep),
                    title: Text('Sign out',
                        style:
                            DawnType.bodyStrong(color: DawnPalette.dawnDeep)),
                    onTap: () async {
                      await PulseRelay.unlinkTraveler();
                      await CircadianBridge.signOut();
                      if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                      if (mounted) setState(() {});
                    },
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.login_rounded,
                        color: DawnPalette.duskDeep),
                    title: Text('Sign in or create a profile',
                        style:
                            DawnType.bodyStrong(color: DawnPalette.duskDeep)),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AccessDeck(
                            onDone: () {
                              Navigator.of(context).maybePop();
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_tab) {
      case 0:
        body = const FlightPlanView();
        break;
      case 1:
        body = const RhythmArcView();
        break;
      case 2:
        body = const InflightCareView();
        break;
      case 3:
        body = const LayoverPlannerView();
        break;
      case 4:
        body = const PrepChecklistView();
        break;
      default:
        body = const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: DawnPalette.canvas,
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(_titles[_tab], style: DawnType.title()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            color: DawnPalette.ink,
            onPressed: _openProfile,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: body,
      bottomNavigationBar: _DawnBar(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _DawnBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _DawnBar({required this.index, required this.onChanged});

  static const _items = [
    (Icons.flight_takeoff_rounded, 'Plan'),
    (Icons.brightness_4_rounded, 'Rhythm'),
    (Icons.water_drop_outlined, 'Care'),
    (Icons.public_rounded, 'Zones'),
    (Icons.checklist_rounded, 'Prep'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DawnPalette.surface,
        border: Border(top: BorderSide(color: DawnPalette.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(_items.length, (i) {
              final selected = i == index;
              final item = _items[i];
              return Expanded(
                child: InkResponse(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? DawnPalette.duskWash
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.$1,
                          size: 22,
                          color: selected
                              ? DawnPalette.duskDeep
                              : DawnPalette.inkFaint,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$2,
                        style: DawnType.caption(
                          color: selected
                              ? DawnPalette.duskDeep
                              : DawnPalette.inkFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
