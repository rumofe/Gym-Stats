import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/database/database_helper.dart';
import 'data/database/initial_data_seeder.dart';
import 'data/notifications/notification_service.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formato de fechas en español
  await initializeDateFormatting('es_ES', null);

  // Bloquear orientación vertical en toda la app
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();

  // Primera ejecución: sembrar datos iniciales en la BD
  if (prefs.getBool(AppConstants.prefSeededDb) != true) {
    final db = await DatabaseHelper.instance.database;
    await InitialDataSeeder.seed(db);
    await prefs.setBool(AppConstants.prefSeededDb, true);
  }

  // Inicializar servicio de notificaciones
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const WorkoutTrackerApp(),
    ),
  );
}

class WorkoutTrackerApp extends ConsumerWidget {
  const WorkoutTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
