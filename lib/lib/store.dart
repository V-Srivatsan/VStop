import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' show ThemeMode;

enum AppTheme { system, light, dark, amoled }

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  static Future<void> set(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clear() async => await _storage.deleteAll();
}

class PrefStore {
  static final _store = SharedPreferencesAsync();

  static Future<void> setSem(String id) async => await _store.setString("sem", id);
  static Future<String> getSem() async => (await _store.getString("sem"))!;

  static Future<void> setName(String name) async => await _store.setString("name", name);
  static Future<String> getName() async => (await _store.getString("name"))!;

  static Future<int> getAttThreshold() async {
    final res = await _store.getInt("attThreshold");
    if (res == null) setAttThreshold(75);
    return res ?? 75;
  }
  static Future<void> setAttThreshold(int val) async => await _store.setInt("attThreshold", val);

  static ValueNotifier<AppTheme> theme = ValueNotifier<AppTheme>(.system);
  static Future<void> setTheme(AppTheme theme) async {
    switch (theme) {
      case .system:
        _store.remove("darkTheme");
        break;
      case .light:
        _store.setBool("darkTheme", false);
        break;
      case .dark:
        _store.setBool("darkTheme", true);
        _store.setBool("amoled", false);
        break;
      case .amoled:
        _store.setBool("darkTheme", true);
        _store.setBool("amoled", true);
        break;
    }
    PrefStore.theme.value = theme;
  }
  static Future<void> getTheme() async {
    final dark = await _store.getBool("darkTheme");
    final amoled = await _store.getBool("amoled") ?? false;
    if (dark == null) theme.value = .system;
    else theme.value = dark ? (amoled ? .amoled : .dark) : .light;
  }

  static Future<bool> getPredictiveGrades() async {
    final res = await _store.getBool("predictiveGrades");
    if (res == null) setPredictiveGrades(true);
    return res ?? true;
  }
  static Future<void> setPredictiveGrades(bool val) async => await _store.setBool("predictiveGrades", val);

  static Future<bool> getACEGrading() async => (await _store.getBool("aceGrading")) ?? false;
  static Future<void> setACEGrading(bool val) async => await _store.setBool("aceGrading", val);

  static Future<void> clear() async => await _store.clear();
}