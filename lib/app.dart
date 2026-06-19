import 'package:flutter/material.dart';

import 'domain/recovery_vault.dart';
import 'screens/boot_deck.dart';
import 'state/recovery_scope.dart';
import 'theme/dawn_theme.dart';

class CircadiaApp extends StatelessWidget {
  final RecoveryVault vault;
  const CircadiaApp({super.key, required this.vault});

  @override
  Widget build(BuildContext context) {
    return RecoveryScope(
      vault: vault,
      child: MaterialApp(
        title: 'Aviator Jetlag Companion',
        debugShowCheckedModeBanner: false,
        theme: DawnTheme.build(),
        home: const BootDeck(),
      ),
    );
  }
}
