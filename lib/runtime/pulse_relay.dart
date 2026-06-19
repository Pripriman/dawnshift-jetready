import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../config/journey_env.dart';

class PulseRelay {
  static bool _started = false;

  static Future<void> wake() async {
    if (_started || !JourneyEnv.hasPulse) return;
    try {
      OneSignal.initialize(JourneyEnv.pulseAppId);
      _started = true;
    } catch (_) {}
  }

  static Future<void> requestConsent() async {
    if (!_started) return;
    try {
      await OneSignal.Notifications.requestPermission(true);
    } catch (_) {}
  }

  static Future<void> linkTraveler(String externalId) async {
    if (!_started) return;
    try {
      await OneSignal.login(externalId);
    } catch (_) {}
  }

  static Future<void> unlinkTraveler() async {
    if (!_started) return;
    try {
      await OneSignal.logout();
    } catch (_) {}
  }
}
