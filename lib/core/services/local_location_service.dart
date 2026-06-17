import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart';

class WardModel {
  const WardModel({required this.name, required this.codename});

  final String name;
  final String codename;

  factory WardModel.fromJson(Map<String, dynamic> json) {
    return WardModel(
      name: json['name']?.toString() ?? '',
      codename: json['codename']?.toString() ?? '',
    );
  }
}

class LocalLocationService {
  static final LocalLocationService _instance = LocalLocationService._internal();
  factory LocalLocationService() => _instance;
  LocalLocationService._internal();

  final Map<String, List<WardModel>> allData = {};
  final Map<String, Map<String, String>> _codenameToNameByCity = {};
  final Map<String, String> _globalCodenameToName = {};
  final Map<String, Map<String, String>> _nameToCodenameByCity = {};
  bool _isLoaded = false;

  static String? cityToAssetKey(String? city) {
    final normalized = removeDiacritics((city ?? '').trim().toLowerCase());
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized.contains('ha noi') || normalized == 'ha_noi') {
      return 'ha_noi';
    }
    if (normalized.contains('ho chi minh') ||
        normalized.contains('hcm') ||
        normalized.contains('tp hcm') ||
        normalized.contains('tp. hcm') ||
        normalized == 'tp_hcm') {
      return 'tp_hcm';
    }
    return null;
  }

  Future<void> loadData() async {
    if (_isLoaded) {
      return;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data_vietnam.json');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      jsonMap.forEach((key, value) {
        if (value is! List) {
          return;
        }
        final wards = value
            .whereType<Map>()
            .map((e) => WardModel.fromJson(Map<String, dynamic>.from(e)))
            .where((w) => w.codename.isNotEmpty && w.name.isNotEmpty)
            .toList();
        allData[key] = wards;

        final codenameToName = <String, String>{};
        final nameToCodename = <String, String>{};
        for (final ward in wards) {
          codenameToName[ward.codename] = ward.name;
          nameToCodename[_fold(ward.name)] = ward.codename;
          _globalCodenameToName[ward.codename] = ward.name;
        }
        _codenameToNameByCity[key] = codenameToName;
        _nameToCodenameByCity[key] = nameToCodename;
      });

      _isLoaded = true;
    } catch (_) {
      _isLoaded = false;
    }
  }

  List<WardModel> getWardsByCityKey(String cityKey) => allData[cityKey] ?? [];

  List<WardModel> wardsForCity(String? city) {
    final key = cityToAssetKey(city);
    if (key == null) {
      return const [];
    }
    return getWardsByCityKey(key);
  }

  /// Hiển thị phường/xã: `phuong_ba_dinh` → `Phường Ba Đình`.
  String wardDisplayName({String? city, required String ward}) {
    final raw = ward.trim();
    if (raw.isEmpty) {
      return '';
    }

    final cityKey = cityToAssetKey(city);
    if (cityKey != null) {
      final byCodename = _codenameToNameByCity[cityKey];
      if (byCodename != null) {
        final fromCodename = byCodename[raw];
        if (fromCodename != null) {
          return fromCodename;
        }
        if (byCodename.containsValue(raw)) {
          return raw;
        }
      }
    }

    final global = _globalCodenameToName[raw];
    if (global != null) {
      return global;
    }

    for (final wards in allData.values) {
      for (final item in wards) {
        if (_fold(item.name) == _fold(raw)) {
          return item.name;
        }
      }
    }

    return raw;
  }

  /// Chuẩn hóa về codename để query Firestore / so khớp filter.
  String? wardCodename({String? city, required String ward}) {
    final raw = ward.trim();
    if (raw.isEmpty) {
      return null;
    }

    final cityKey = cityToAssetKey(city);
    if (cityKey != null) {
      final byCodename = _codenameToNameByCity[cityKey];
      if (byCodename != null && byCodename.containsKey(raw)) {
        return raw;
      }
      final fromName = _nameToCodenameByCity[cityKey]?[_fold(raw)];
      if (fromName != null) {
        return fromName;
      }
    }

    if (_globalCodenameToName.containsKey(raw)) {
      return raw;
    }

    for (final entry in _nameToCodenameByCity.entries) {
      final hit = entry.value[_fold(raw)];
      if (hit != null) {
        return hit;
      }
    }

    return raw.contains('_') ? raw : null;
  }

  Set<String> wardCodenamesForQuery({String? city, required Set<String> wards}) {
    final out = <String>{};
    for (final ward in wards) {
      final code = wardCodename(city: city, ward: ward);
      if (code != null && code.isNotEmpty) {
        out.add(code);
      }
    }
    return out;
  }

  bool wardsMatch({
    String? city,
    required String propertyWard,
    required String selectedWard,
  }) {
    final a = propertyWard.trim();
    final b = selectedWard.trim();
    if (a.isEmpty || b.isEmpty) {
      return false;
    }
    if (a == b) {
      return true;
    }

    final codeA = wardCodename(city: city, ward: a);
    final codeB = wardCodename(city: city, ward: b);
    if (codeA != null && codeB != null && codeA == codeB) {
      return true;
    }

    final nameA = wardDisplayName(city: city, ward: a);
    final nameB = wardDisplayName(city: city, ward: b);
    return _fold(nameA) == _fold(nameB);
  }

  static String _fold(String value) =>
      removeDiacritics(value.trim().toLowerCase()).replaceAll(RegExp(r'\s+'), ' ');
}
