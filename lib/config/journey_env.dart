class JourneyEnv {
  static const String supabaseUrl = String.fromEnvironment('SB_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SB_ANON');
  static const String pulseAppId = String.fromEnvironment('OS_APP_ID');
  static const String phaseAppId = String.fromEnvironment('AFF_APP_ID');
  static const String phaseSecret = String.fromEnvironment('AFF_SECRET');

  static const int gateTimeoutSeconds = 8;
  static const int endpointProbeSeconds = 6;
  static const Duration endpointCacheTtl = Duration(hours: 24);

  static bool get hasBackend =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasPulse => pulseAppId.isNotEmpty;
  static bool get hasPhase => phaseAppId.isNotEmpty && phaseSecret.isNotEmpty;
}
