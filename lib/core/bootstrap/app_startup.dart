import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/features/draw/data/datasources/saved_drawings_local_datasource.dart';
import 'package:lueur/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur/features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import 'package:lueur/features/sudoku/data/datasources/sudoku_results_local_datasource.dart';
import 'package:lueur/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hive box opening, SharedPreferences, and DI registration — kept out of
/// main() so runApp() can draw the first frame immediately. Called after
/// runApp(); Lueur (core/app.dart) shows a loading state until this
/// completes, since `sl<T>()` cubits aren't registered before then.
Future<void> initializeAppServices() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  unawaited(FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true));

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<String>(MoodLocalDatasource.boxName),
    Hive.openBox<String>(SavedQuotesLocalDatasource.boxName),
    Hive.openBox<String>(SudokuResultsLocalDatasource.boxName),
    Hive.openBox<String>(SavedDrawingsLocalDatasource.boxName),
  ]);
  // Guest entries are session-only. Clear only the anonymous key; cached
  // histories belonging to registered Firebase UIDs remain untouched.
  await MoodLocalDatasource().clearGuestHistory();

  final sharedPreferences = await SharedPreferences.getInstance();
  setupInjection(sharedPreferences: sharedPreferences);
}
