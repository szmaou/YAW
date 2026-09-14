import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? s}) : _secure = s ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  static const _secureOnlyKeys = {StorageKeys.token, StorageKeys.refreshToken};

  Future<String?> read(String key) async {
    if (_secureOnlyKeys.contains(key)) {
      try {
        return await _secure.read(key: key);
      } catch (_) {
        return null; // secure read failed → null (no fallback)
      }
    }
    // non-sensitive: secure first, SharedPreferences fallback
    try {
      return await _secure.read(key: key);
    } catch (_) {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(key);
    }
  }

  Future<void> write(String key, String value) async {
    if (_secureOnlyKeys.contains(key)) {
      await _secure.write(key: key, value: value); // rethrow on failure
      return;
    }
    // non-sensitive: secure first, SharedPreferences fallback
    try {
      await _secure.write(key: key, value: value);
    } catch (_) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(key, value);
    }
  }

  Future<void> delete(String key) async {
    if (_secureOnlyKeys.contains(key)) {
      await _secure.delete(key: key); // rethrow on failure
      return;
    }
    // non-sensitive: secure first, SharedPreferences fallback
    try {
      await _secure.delete(key: key);
    } catch (_) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(key);
    }
  }

  Future<void> clear() async {
    // clear all secure keys; best-effort for non-sensitive
    try {
      await _secure.deleteAll();
    } catch (_) {}
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.clear();
    } catch (_) {}
  }
}