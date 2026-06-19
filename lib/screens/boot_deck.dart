import 'package:flutter/material.dart';

import '../runtime/deck_gate.dart';
import '../runtime/phase_beacon.dart';
import '../theme/dawn_palette.dart';
import '../theme/dawn_type.dart';
import 'bad_connection_deck.dart';
import 'content/circadian_deck_view.dart';
import 'native_root.dart';

class BootDeck extends StatefulWidget {
  const BootDeck({super.key});

  @override
  State<BootDeck> createState() => _BootDeckState();
}

class _BootDeckState extends State<BootDeck>
    with SingleTickerProviderStateMixin {
  late Future<DeckResult> _future;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _future = DeckGate.resolve();
  }

  void _retry() {
    setState(() {
      _future = DeckGate.resolve();
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeckResult>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _splash();
        }
        final result = snap.data ?? const DeckResult(DeckOutcome.native);
        switch (result.outcome) {
          case DeckOutcome.badConnection:
            return BadConnectionDeck(onRetry: _retry);
          case DeckOutcome.content:
            PhaseBeacon.contentOpen();
            return CircadianDeckView(endpoint: result.endpoint!);
          case DeckOutcome.native:
            return const NativeRoot();
        }
      },
    );
  }

  Widget _splash() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DawnPalette.skylineGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final glow = 0.4 + _pulse.value * 0.5;
                  return Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [DawnPalette.dawn, DawnPalette.dusk],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DawnPalette.dusk.withValues(alpha: glow * 0.4),
                          blurRadius: 38,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.brightness_4_rounded,
                        color: Colors.white, size: 44),
                  );
                },
              ),
              const SizedBox(height: 26),
              Text('Reading your rhythm…',
                  style: DawnType.heading(color: DawnPalette.duskDeep)),
            ],
          ),
        ),
      ),
    );
  }
}
