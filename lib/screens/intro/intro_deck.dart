import 'package:flutter/material.dart';
import '../../theme/dawn_palette.dart';
import '../../theme/dawn_type.dart';
import '../../widgets/glide_button.dart';

class _Panel {
  final IconData icon;
  final Color tint;
  final String title;
  final String body;
  const _Panel(this.icon, this.tint, this.title, this.body);
}

class IntroDeck extends StatefulWidget {
  final VoidCallback onDone;
  const IntroDeck({super.key, required this.onDone});

  @override
  State<IntroDeck> createState() => _IntroDeckState();
}

class _IntroDeckState extends State<IntroDeck> {
  final _controller = PageController();
  int _index = 0;

  static const _panels = [
    _Panel(
        Icons.wb_twilight_rounded,
        DawnPalette.dawn,
        'Beat the jetlag',
        'Tell us your departure, arrival and time zones, and we turn them into a personal circadian plan — when to seek light, when to dim it, and how to shift sleep.'),
    _Panel(
        Icons.brightness_4_rounded,
        DawnPalette.dusk,
        'See your day as an arc',
        'A gentle sun-and-moon arc maps each day before and after your flight, with coloured windows for light, rest and movement that you can read at a glance.'),
    _Panel(
        Icons.water_drop_outlined,
        DawnPalette.noon,
        'Stay fresh in the air',
        'In-flight reminders pace your hydration and movement, and a layover guide helps you turn connections into recovery time.'),
    _Panel(
        Icons.checklist_rounded,
        DawnPalette.rested,
        'Land ready',
        'A travel checklist and an arrival-readiness gauge keep you organised — all of it works fully offline, no account required.'),
  ];

  bool get _last => _index == _panels.length - 1;

  void _next() {
    if (_last) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DawnPalette.skylineGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: AnimatedOpacity(
                    opacity: _last ? 0 : 1,
                    duration: const Duration(milliseconds: 220),
                    child: QuietLink(
                      label: 'Skip',
                      onPressed: _last ? null : widget.onDone,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _panels.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = _panels[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: 168,
                            height: 168,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: p.tint.withValues(alpha: 0.28),
                                  blurRadius: 36,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Icon(p.icon, size: 64, color: p.tint),
                          ),
                          const SizedBox(height: 44),
                          Text(p.title,
                              style: DawnType.title(),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 14),
                          Text(p.body,
                              style: DawnType.body(),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_panels.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? DawnPalette.dusk : DawnPalette.hairline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 28),
                child: GlideButton(
                  label: _last ? 'Start planning' : 'Next',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
