import 'package:ai_therapist_app/core/styling/app_extra_colors.dart';
import 'package:flutter/material.dart';

extension ExtraColorsExtension on BuildContext {
  AppExtraColors get extra => Theme.of(this).extension<AppExtraColors>()!;
}
