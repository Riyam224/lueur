import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur_app/core/cubits/theme_cubit.dart';
import 'package:lueur_app/core/injection/injection.dart';
import 'package:lueur_app/core/routing/router_generation_config.dart';
import 'package:lueur_app/core/styling/app_theme.dart';

class Lueur extends StatelessWidget {
  const Lueur({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Lueur',
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                routerConfig: RouterGenerationConfig.goRouter,
              );
            },
          );
        },
      ),
    );
  }
}
