class Validators {
  Validators._();
  static String? required(String? v, String field) {
    if (v == null || v.trim().isEmpty) return '$field wajib diisi';
    return null;
  }
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!r.hasMatch(v.trim())) return 'Format email tidak valid';
    return null;
  }
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password wajib diisi';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (v.trim().length < 9) return 'No. HP tidak valid';
    return null;
  }
}
