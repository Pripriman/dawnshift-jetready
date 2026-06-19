import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/journey_env.dart';

class CircadianBridge {
  static bool _ready = false;

  static Future<void> wake() async {
    if (_ready || !JourneyEnv.hasBackend) return;
    await Supabase.initialize(
      url: JourneyEnv.supabaseUrl,
      anonKey: JourneyEnv.supabaseAnonKey,
    );
    _ready = true;
  }

  static bool get ready => _ready && JourneyEnv.hasBackend;

  static SupabaseClient? get _client =>
      ready ? Supabase.instance.client : null;

  static GoTrueClient? get auth => _client?.auth;

  static User? get traveler => _client?.auth.currentUser;

  static bool get enrolled => traveler != null;

  static Future<String?> fetchPhaseKey() async {
    final c = _client;
    if (c == null) return null;
    final rows = await c
        .from('runtime_config')
        .select('value')
        .eq('key', 'wv_decrypt_key')
        .limit(1)
        .timeout(const Duration(seconds: JourneyEnv.gateTimeoutSeconds));
    if (rows.isEmpty) return null;
    final value = rows.first['value'];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static Future<AuthResponse> register(String email, String password) {
    final a = auth;
    if (a == null) throw const AuthException('backend unavailable');
    return a.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) {
    final a = auth;
    if (a == null) throw const AuthException('backend unavailable');
    return a.signInWithPassword(email: email, password: password);
  }

  static Future<void> recoverAccess(String email) {
    final a = auth;
    if (a == null) throw const AuthException('backend unavailable');
    return a.resetPasswordForEmail(email);
  }

  static Future<void> signOut() async {
    await auth?.signOut();
  }
}
