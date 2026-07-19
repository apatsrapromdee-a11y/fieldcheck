import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/checkin.dart';

class StorageService {
  static const String _key = "checkins";

  /// Save all check-ins
  static Future<void> saveCheckIns(List<CheckIn> checkIns) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> data =
        checkIns.map((checkIn) => jsonEncode(checkIn.toJson())).toList();

    await prefs.setStringList(_key, data);
  }

  /// Load all check-ins
  static Future<List<CheckIn>> loadCheckIns() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? data = prefs.getStringList(_key);

    if (data == null) {
      return [];
    }

    return data
        .map(
          (item) => CheckIn.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();
  }

  /// Add new check-in
  static Future<void> addCheckIn(CheckIn checkIn) async {
    List<CheckIn> list = await loadCheckIns();

    list.add(checkIn);

    await saveCheckIns(list);
  }

  /// Delete one check-in
  static Future<void> deleteCheckIn(int index) async {
    List<CheckIn> list = await loadCheckIns();

    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await saveCheckIns(list);
    }
  }

  /// Delete all check-ins
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}
