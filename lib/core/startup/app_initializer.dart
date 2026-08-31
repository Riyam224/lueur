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

/// Runs the app's async startup sequence, kept out of main() so runApp() can
/// draw the first frame immediately; Lueur shows a loading state until this completes.
Future<void> initializeAppServices() async {
  await _initializeFirebase();
  await _openHiveBoxes();
  await _clearGuestOnlyData();
  await _initializeDependencyInjection();
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  unawaited(FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true));
}

Future<void> _openHiveBoxes() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<String>(MoodLocalDatasource.boxName),
    Hive.openBox<String>(SavedQuotesLocalDatasource.boxName),
    Hive.openBox<String>(SudokuResultsLocalDatasource.boxName),
    Hive.openBox<String>(SavedDrawingsLocalDatasource.boxName),
  ]);
}

/// Guest entries are session-only. Clears only the anonymous key; cached
/// histories belonging to registered Firebase UIDs remain untouched.
Future<void> _clearGuestOnlyData() async {
  await MoodLocalDatasource().clearGuestHistory();
}

Future<void> _initializeDependencyInjection() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  setupInjection(sharedPreferences: sharedPreferences);
}
