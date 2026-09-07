import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  SecureStorage({FlutterSecureStorage? s}) : _secure = s ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  Future<String?> read(String key) async {
    try {
      return await _secure.read(key: key);
    } catch (_) {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(key);
    }
  }

  Future<void> write(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
    } catch (_) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(key, value);
    }
  }

  Future<void> delete(String key) async {
    try {
      await _secure.delete(key: key);
    } catch (_) {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(key);
    }
  }

  Future<void> clear() async {
    try {
      await _secure.deleteAll();
    } catch (_) {
      final sp = await SharedPreferences.getInstance();
      await sp.clear();
    }
  }
}
