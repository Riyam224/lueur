import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lueur_app/core/app.dart';
import 'package:lueur_app/core/cubits/theme_cubit.dart';
import 'package:lueur_app/core/injection/injection.dart';
import 'package:lueur_app/features/home/data/datasources/mood_local_datasource.dart';
import 'package:lueur_app/features/quotes/data/datasources/saved_quotes_local_datasource.dart';
import 'package:lueur_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // local storage
  await Hive.initFlutter();
  await Hive.openBox<String>(MoodLocalDatasource.boxName);
  await Hive.openBox<String>(SavedQuotesLocalDatasource.boxName);
  await Hive.openBox<bool>(ThemeCubit.boxName);

  setupInjection();

  await GoogleFonts.pendingFonts([
    GoogleFonts.dmSans(),
    GoogleFonts.dmSerifDisplay(),
  ]);
// this is App.dart file the rest of the code
  runApp(const Lueur());
}
