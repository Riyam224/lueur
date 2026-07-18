import 'package:flutter/material.dart';
import 'package:lueur_app/core/styling/app_extra_colors.dart';

extension ExtraColorsExtension on BuildContext {
  AppExtraColors get extra => Theme.of(this).extension<AppExtraColors>()!;
}
