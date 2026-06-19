import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/journey_env.dart';
import '../config/route_seal.dart';
import 'circadian_bridge.dart';
import 'seal_opener.dart';

enum DeckOutcome { content, native, badConnection }

class DeckResult {
  final DeckOutcome outcome;
  final String? endpoint;
  const DeckResult(this.outcome, [this.endpoint]);
}

class DeckGate {
  static const _endpointKey = 'circ.endpoint';
  static const _storage = FlutterSecureStorage();

  static Future<DeckResult> resolve() async {
    final cached = await _freshEndpoint();
    if (cached != null) {
      return DeckResult(DeckOutcome.content, cached);
    }

    if (!JourneyEnv.hasBackend) {
      return const DeckResult(DeckOutcome.native);
    }

    String? phaseKey;
    try {
      phaseKey = await CircadianBridge.fetchPhaseKey();
    } catch (_) {
      return const DeckResult(DeckOutcome.badConnection);
    }

    if (phaseKey == null || phaseKey.isEmpty) {
      return const DeckResult(DeckOutcome.native);
    }

    final destination =
        await SealOpener.open(RouteSeal.forPlatform(), phaseKey);
    if (destination == null || destination.isEmpty) {
      return const DeckResult(DeckOutcome.native);
    }

    final reachable = await _probe(destination);
    if (!reachable) {
      return const DeckResult(DeckOutcome.native);
    }

    await _storeEndpoint(destination);
    return DeckResult(DeckOutcome.content, destination);
  }

  static Future<bool> _probe(String destination) async {
    try {
      final resp = await http
          .get(Uri.parse(destination))
          .timeout(const Duration(seconds: JourneyEnv.endpointProbeSeconds));
      if (resp.statusCode != 200) return false;
      return resp.bodyBytes.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _freshEndpoint() async {
    try {
      final raw = await _storage.read(key: _endpointKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final destination = map['endpoint'] as String?;
      final stamp = map['stamp'] as int?;
      if (destination == null || stamp == null) return null;
      final age = DateTime.now().millisecondsSinceEpoch - stamp;
      if (age > JourneyEnv.endpointCacheTtl.inMilliseconds) return null;
      return destination;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _storeEndpoint(String destination) async {
    try {
      final payload = jsonEncode({
        'endpoint': destination,
        'stamp': DateTime.now().millisecondsSinceEpoch,
      });
      await _storage.write(key: _endpointKey, value: payload);
    } catch (_) {}
  }

  static Future<void> clearEndpoint() async {
    try {
      await _storage.delete(key: _endpointKey);
    } catch (_) {}
  }
}
