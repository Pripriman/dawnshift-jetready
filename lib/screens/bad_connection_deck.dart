import 'package:flutter/material.dart';
import '../theme/dawn_palette.dart';
import '../theme/dawn_type.dart';
import '../widgets/glide_button.dart';

class BadConnectionDeck extends StatelessWidget {
  final VoidCallback onRetry;
  const BadConnectionDeck({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DawnPalette.skylineGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: DawnPalette.duskWash,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_off_rounded,
                      size: 38, color: DawnPalette.duskDeep),
                ),
                const SizedBox(height: 24),
                Text('We lost the horizon',
                    style: DawnType.title(), textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(
                  'We could not reach your travel profile. Check your connection and try again — your offline plan is still here.',
                  style: DawnType.body(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                GlideButton(
                  label: 'Try again',
                  icon: Icons.refresh_rounded,
                  expand: false,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
