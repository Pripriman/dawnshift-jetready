import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'domain/recovery_vault.dart';
import 'runtime/circadian_bridge.dart';
import 'runtime/phase_beacon.dart';
import 'runtime/pulse_relay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await CircadianBridge.wake();
  } catch (_) {}

  await PulseRelay.wake();
  PhaseBeacon.wake();

  final vault = RecoveryVault();
  await vault.load();

  await _markFirstOpen();

  runApp(CircadiaApp(vault: vault));
}

Future<void> _markFirstOpen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const key = 'circ.firstOpenSent';
    if (!(prefs.getBool(key) ?? false)) {
      PhaseBeacon.firstOpen();
      await prefs.setBool(key, true);
    }
  } catch (_) {}
}
