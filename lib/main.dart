import 'dart:async';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lueur/core/app.dart';
import 'package:lueur/core/bootstrap/app_startup.dart';
import 'package:lueur/core/monitoring/sentry_privacy_filter.dart';
import 'package:lueur/firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  const appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // DM Sans is bundled locally (assets/fonts/DMSans-Variable.ttf) — never
  // fetch fonts over the network at runtime, which used to block cold
  // starts on a call to Google's font CDN.
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  unawaited(FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true));

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

      // Hive, SharedPreferences, and DI setup run in the background —
      // runApp() draws the first frame immediately instead of waiting on
      // them. Lueur shows a loading state until this future completes.
      runApp(Lueur(initialization: initializeAppServices()));
    },
  );
}
