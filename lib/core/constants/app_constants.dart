class AppConstants {
  AppConstants._();
  static const String appName = 'YAW';
  static const String appTagline = 'THE FUTURE\nOF MOBILITY';
  static const String appSubtitle = 'Discover vehicles built for tomorrow.';
  static const String version = '1.0.0';
}

class ApiConstants {
  ApiConstants._();
  // Backend sesuai backend/.env → APP_PORT=3002
  // Android emulator: http://10.0.2.2:3002/api/v1
  // Web/desktop: http://localhost:3002/api/v1
  static const String baseUrl = 'http://localhost:3002/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Vehicles & categories
  static const String vehicles = '/vehicles';
  static const String categories = '/categories';
  static const String upload = '/upload';

  // Origin server (tanpa path /api/v1) — dipakai untuk menampilkan URL relatif.
  static String get serverOrigin {
    final apiIdx = baseUrl.indexOf('/api');
    return apiIdx > 0 ? baseUrl.substring(0, apiIdx) : baseUrl;
  }

  /// Ubah path relatif backend (/uploads/...) jadi URL absolut agar
  /// CachedNetworkImage / Image.network bisa menampilkannya.
  /// Jika sudah HTTP, dikembalikan apa adanya; selain itu (empty/path/query)
  /// dikembalikan apa adanya.
  static String resolveImageUrl(String u) {
    final t = u.trim();
    if (t.isEmpty) return '';
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    if (t.startsWith('/')) return '$serverOrigin$t';
    return t;
  }

  // Favorites / Orders / Users / Admin
  static const String favorites = '/favorites';
  static const String orders = '/orders';
  static const String users = '/users';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStatistics = '/admin/statistics';
}

class StorageKeys {
  StorageKeys._();
  static const String token = 'yaw_token';
  static const String refreshToken = 'yaw_refresh_token';
  static const String userJson = 'yaw_user';
  static const String onboardingDone = 'yaw_onboarding_done';
}

class Breakpoints {
  Breakpoints._();
  static const double mobile = 600;
  static const double tablet = 1024;
}
