import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lueur/core/app.dart';
import 'package:lueur/core/monitoring/sentry_privacy_filter.dart';
import 'package:lueur/core/startup/app_initializer.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  const appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // DM Sans is bundled locally — never fetch fonts at runtime, which used
  // to block cold starts on a call to Google's font CDN.
  GoogleFonts.config.allowRuntimeFetching = false;

  void runLueur() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (sentryDsn.isNotEmpty) {
        unawaited(
          Sentry.captureException(
            details.exception,
            stackTrace: details.stack,
          ),
        );
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (sentryDsn.isNotEmpty) {
        unawaited(Sentry.captureException(error, stackTrace: stack));
      }
      return true;
    };

    // Firebase, Hive, SharedPreferences, and DI initialize behind a Flutter
    // loading screen, allowing Android's native splash to hand off promptly.
    runApp(Lueur(initialization: initializeAppServices()));
  }

  // Initializing the native Sentry SDK is expensive on a cold emulator. Do
  // not pay that startup cost in local/dev builds where no DSN is configured.
  if (sentryDsn.isEmpty) {
    runLueur();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment = appEnvironment;
      options.tracesSampleRate = 0.2;
      options.sendDefaultPii = false;
      options.enableAutoPerformanceTracing = true;
      options.beforeSend = scrubSensitiveSentryData;
    },
    appRunner: runLueur,
  );
}
