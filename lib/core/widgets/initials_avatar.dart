import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/app_fonts.dart';

/// Circular avatar showing the user's first initial (falls back to a generic
/// person icon). Background color is deterministic from [seed], so the same user always gets the same color.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.diameter,
    this.name,
    this.seed,
  });

  /// Display name (or email) used to derive the initial shown.
  final String? name;

  /// Stable identifier (user id/email) used to pick a background color.
  /// Falls back to [name] when not provided.
  final String? seed;

  final double diameter;

  // All light pastels — lightOnBackground reads with sufficient contrast
  // (>4.5:1) against every color in this set.
  static const List<Color> _backgroundColors = [
    AppColors.journalCardLavender,
    AppColors.journalCardMint,
    AppColors.journalCardPeach,
    AppColors.journalCardCoral,
    AppColors.pastelPeriwinkle,
  ];

  static const Color _textColor = AppColors.lightOnBackground;

  String? get _initial {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed[0].toUpperCase();
  }

  Color get _backgroundColor {
    final trimmedSeed = seed?.trim();
    final key = (trimmedSeed != null && trimmedSeed.isNotEmpty)
        ? trimmedSeed
        : name?.trim();
    if (key == null || key.isEmpty) return _backgroundColors.first;
    return _backgroundColors[key.hashCode.abs() % _backgroundColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initial = _initial;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColor,
      ),
      alignment: Alignment.center,
      child: initial == null
          ? Icon(
              Icons.person_rounded,
              size: diameter * 0.5,
              color: _textColor,
            )
          : Text(
              initial,
              style: TextStyle(
                fontFamily: AppFonts.mainFontName,
                fontSize: diameter * 0.42,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
    );
  }
}
