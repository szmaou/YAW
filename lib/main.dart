import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load Indonesian date symbols before any widget (and therefore any
  // Formatters usage) builds, otherwise `DateFormat('...', 'id_ID')` throws a
  // LocaleDataException on the OrdersPage and AdminDashboardPage.
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: YawApp()));
}
