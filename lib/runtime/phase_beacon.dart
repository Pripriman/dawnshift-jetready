import 'package:affise_attribution_lib/affise.dart';
import '../config/journey_env.dart';

class PhaseBeacon {
  static bool _started = false;

  static void wake() {
    if (_started || !JourneyEnv.hasPhase) return;
    try {
      Affise
          .settings(
            affiseAppId: JourneyEnv.phaseAppId,
            secretKey: JourneyEnv.phaseSecret,
          )
          .setProduction(true)
          .start();
      _started = true;
    } catch (_) {}
  }

  static void _emit(String name) {
    if (!_started) return;
    try {
      Affise.sendEvent(UserCustomEvent(eventName: name));
    } catch (_) {}
  }

  static void firstOpen() => _emit('first_open');
  static void registration() => _emit('registration');
  static void login() => _emit('login');
  static void contentOpen() => _emit('content_open');
}
