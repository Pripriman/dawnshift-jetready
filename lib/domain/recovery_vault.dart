import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'prep_models.dart';

class RecoveryVault extends ChangeNotifier {
  static const _itemsKey = 'circ.prepItems';
  static const _flagsKey = 'circ.readinessFlags';
  static const _uuid = Uuid();

  final List<PrepItem> _items = [];
  bool _sleepShiftStarted = false;
  bool _lightPlanFollowed = false;
  bool _hydrationOnTrack = false;
  bool _loaded = false;

  List<PrepItem> get items => List.unmodifiable(_items);
  bool get isLoaded => _loaded;
  bool get sleepShiftStarted => _sleepShiftStarted;
  bool get lightPlanFollowed => _lightPlanFollowed;
  bool get hydrationOnTrack => _hydrationOnTrack;

  int get packedCount => _items.where((e) => e.packed).length;

  double get packedFraction =>
      _items.isEmpty ? 0 : packedCount / _items.length;

  ReadinessSignals get signals => ReadinessSignals(
        sleepShiftStarted: _sleepShiftStarted,
        lightPlanFollowed: _lightPlanFollowed,
        hydrationOnTrack: _hydrationOnTrack,
        packedFraction: packedFraction,
      );

  static const List<String> _defaults = [
    'Eye mask for blackout sleep',
    'Noise-cancelling earplugs',
    'Refillable water bottle',
    'Blue-light glasses',
    'Phone and headphone chargers',
    'Compression socks',
    'Light snack for the new schedule',
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _items.clear();
    final raw = prefs.getString(_itemsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final e in list) {
          _items.add(PrepItem.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {}
    }
    if (_items.isEmpty) {
      for (final title in _defaults) {
        _items.add(PrepItem(id: _uuid.v4(), title: title));
      }
    }

    final flags = prefs.getString(_flagsKey);
    if (flags != null && flags.isNotEmpty) {
      try {
        final map = jsonDecode(flags) as Map<String, dynamic>;
        _sleepShiftStarted = map['sleepShift'] as bool? ?? false;
        _lightPlanFollowed = map['lightPlan'] as bool? ?? false;
        _hydrationOnTrack = map['hydration'] as bool? ?? false;
      } catch (_) {}
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _persistItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _itemsKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  Future<void> _persistFlags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _flagsKey,
      jsonEncode({
        'sleepShift': _sleepShiftStarted,
        'lightPlan': _lightPlanFollowed,
        'hydration': _hydrationOnTrack,
      }),
    );
  }

  Future<void> togglePacked(String id) async {
    final item = _items.firstWhere((e) => e.id == id);
    item.packed = !item.packed;
    await _persistItems();
    notifyListeners();
  }

  Future<void> addItem(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    _items.add(PrepItem(id: _uuid.v4(), title: trimmed, custom: true));
    await _persistItems();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _persistItems();
    notifyListeners();
  }

  Future<void> setSleepShift(bool value) async {
    _sleepShiftStarted = value;
    await _persistFlags();
    notifyListeners();
  }

  Future<void> setLightPlan(bool value) async {
    _lightPlanFollowed = value;
    await _persistFlags();
    notifyListeners();
  }

  Future<void> setHydration(bool value) async {
    _hydrationOnTrack = value;
    await _persistFlags();
    notifyListeners();
  }
}
