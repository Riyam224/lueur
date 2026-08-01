import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/app.dart';
import 'package:lueur/core/cubits/theme_cubit.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/monitoring/sentry_privacy_filter.dart';
import 'package:lueur/features/draw/data/datasources/saved_drawings_local_datasource.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import 'package:lueur/features/sudoku/data/datasources/sudoku_results_local_datasource.dart';
import 'package:lueur/firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  const appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // local storage _
  await Hive.initFlutter();
  await Hive.openBox<String>(MoodLocalDatasource.boxName);
  await Hive.openBox<String>(SavedQuotesLocalDatasource.boxName);
  await Hive.openBox<String>(SudokuResultsLocalDatasource.boxName);
  await Hive.openBox<String>(SavedDrawingsLocalDatasource.boxName);
  await Hive.openBox<bool>(ThemeCubit.boxName);
  final sharedPreferences = await SharedPreferences.getInstance();

  setupInjection(sharedPreferences: sharedPreferences);

  await GoogleFonts.pendingFonts([
    GoogleFonts.dmSans(),
    GoogleFonts.dmSerifDisplay(),
  ]);

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment = appEnvironment;
      options.tracesSampleRate = 0.2;
      options.sendDefaultPii = false;
      options.enableAutoPerformanceTracing = true;
      options.beforeSend = scrubSensitiveSentryData;
    },
    appRunner: () {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        if (sentryDsn.isNotEmpty) {
          Sentry.captureException(
            details.exception,
            stackTrace: details.stack,
          );
        }
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        if (sentryDsn.isNotEmpty) {
          Sentry.captureException(error, stackTrace: stack);
        }
        return true;
      };

      runApp(const Lueur());

      Future.delayed(const Duration(seconds: 5), () {
        Sentry.captureException(
          Exception('Hotspot test — Sentry Flutter verification'),
          stackTrace: StackTrace.current,
        );
      });
    },
  );
}
