import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebStorageService {
  static WebStorageService? _instance;
  late SharedPreferences _prefs;

  WebStorageService._();

  static Future<WebStorageService> getInstance() async {
    if (_instance == null) {
      _instance = WebStorageService._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    if (kIsWeb) {
      await _restoreFromLocalStorageIfNeeded();
    }
  }

  Future<void> setValue(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      final jsonStr = jsonEncode(value);
      await _prefs.setString(key, jsonStr);
    }

    if (kIsWeb) {
      await _backupAllDataToLocalStorage();
    }
  }

  Future<void> _backupAllDataToLocalStorage() async {
    if (kIsWeb) {
      final allData = _prefs.getKeys().map((key) {
        return MapEntry(key, _prefs.get(key));
      }).toList();

      final jsonStr = jsonEncode(allData);
      // ignore: avoid_web_libraries_in_flutter
      import 'web_storage_base.dart' show WebStorageBase;
      WebStorageBase.setItem('shared_preferences_backup', jsonStr);
    }
  }

  Future<void> _restoreFromLocalStorageIfNeeded() async {
    if (kIsWeb) {
      // ignore: avoid_web_libraries_in_flutter
      import 'web_storage_base.dart' show WebStorageBase;
      final backupStr = WebStorageBase.getItem('shared_preferences_backup');
      if (backupStr != null) {
        try {
          final List<dynamic> allData = jsonDecode(backupStr);
          for (final entry in allData) {
            final key = entry['key'] as String;
            final value = entry['value'];
            await setValue(key, value);
          }
        } catch (e) {
          print('Error restoring from localStorage: $e');
        }
      }
    }
  }

  dynamic getValue(String key, {dynamic defaultValue}) {
    return _prefs.get(key) ?? defaultValue;
  }

  Future<void> removeValue(String key) async {
    await _prefs.remove(key);
    if (kIsWeb) {
      await _backupAllDataToLocalStorage();
    }
  }

  Future<void> clear() async {
    await _prefs.clear();
    if (kIsWeb) {
      // ignore: avoid_web_libraries_in_flutter
      import 'web_storage_base.dart' show WebStorageBase;
      WebStorageBase.setItem('shared_preferences_backup', '[]');
    }
  }
}