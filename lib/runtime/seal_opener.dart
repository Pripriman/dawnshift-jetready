import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class SealOpener {
  static Future<String?> open(String sealedB64, String hexKey) async {
    try {
      final raw = base64.decode(_normalize(sealedB64));
      if (raw.length < 28) return null;
      final nonce = raw.sublist(0, 12);
      final tag = raw.sublist(raw.length - 16);
      final cipher = raw.sublist(12, raw.length - 16);
      final keyBytes = _hexToBytes(hexKey.trim());
      if (keyBytes.length != 32) return null;
      final algo = AesGcm.with256bits();
      final box = SecretBox(cipher, nonce: nonce, mac: Mac(tag));
      final clear = await algo.decrypt(box, secretKey: SecretKey(keyBytes));
      final destination = utf8.decode(clear);
      if (!destination.startsWith('http')) return null;
      return destination;
    } catch (_) {
      return null;
    }
  }

  static String _normalize(String value) {
    var s = value.trim().replaceAll('-', '+').replaceAll('_', '/');
    final pad = s.length % 4;
    if (pad != 0) s = s.padRight(s.length + (4 - pad), '=');
    return s;
  }

  static List<int> _hexToBytes(String hex) {
    final clean = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final out = <int>[];
    for (var i = 0; i + 1 < clean.length; i += 2) {
      out.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return out;
  }
}
