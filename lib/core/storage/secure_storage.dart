import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token dkk disimpan di secure storage bila tersedia, dengan fallback ke
/// SharedPreferences (localStorage di web) bila secure storage melempar.
/// Fallback ini WAJIB ada: FlutterSecureStorageWeb hanya jalan di secure
/// context (https:// atau localhost), sehingga web via http://IP selalu
/// melempar UnsupportedError — tanpa fallback, login gagal tepat setelah
/// server mengembalikan 200 + token (write token melempar duluan).
class SecureStorage {
  SecureStorage({FlutterSecureStorage? s}) : _secure = s ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secure;

  Future<String?> read(String key) async {
    try {
      final v = await _secure.read(key: key);
      if (v != null) return v;
    } catch (_) {}
    try {
      final sp = await SharedPreferences.getInstance();
      return sp.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
      return;
    } catch (_) {}
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
  }

  Future<void> delete(String key) async {
    try {
      await _secure.delete(key: key);
    } catch (_) {}
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(key);
    } catch (_) {}
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