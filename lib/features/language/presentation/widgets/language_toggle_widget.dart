import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/language/domain/entities/app_language.dart';
import 'package:lueur/features/language/presentation/cubit/language_cubit.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Two-option English / Arabic segmented toggle for the Settings screen.
class LanguageToggleWidget extends StatelessWidget {
  const LanguageToggleWidget({super.key});

  Future<void> _changeLanguage(BuildContext context, AppLanguage language) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final succeeded = await context.read<LanguageCubit>().changeLanguage(language);
    if (succeeded) return;
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.languageChangeFailedSnack)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = AppLanguage.fromCode(
      context.watch<LanguageCubit>().state.languageCode,
    );

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageOption(
            label: 'English',
            selected: currentLanguage == AppLanguage.en,
            onTap: () => _changeLanguage(context, AppLanguage.en),
          ),
          _LanguageOption(
            label: 'العربي',
            selected: currentLanguage == AppLanguage.ar,
            onTap: () => _changeLanguage(context, AppLanguage.ar),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? cs.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusXs),
        ),
        child: Text(
          label,
          style: ThemeTextStyles.bodyMedium(context).copyWith(
            color: selected ? cs.onPrimary : null,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
