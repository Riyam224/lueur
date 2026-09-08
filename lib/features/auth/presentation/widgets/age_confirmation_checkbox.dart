import 'package:flutter/material.dart';
import 'package:lueur/core/styling/app_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// Self-declaration checkbox confirming the user is 18 or older, shown
/// between the password fields and the register CTA. This flag is never
/// sent to the backend, but is persisted locally per-uid via
/// AgeConfirmationPrefs once auth succeeds, so returning users aren't
/// re-prompted.
class AgeConfirmationCheckbox extends StatelessWidget {
  const AgeConfirmationCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.primaryColor,
    required this.textPrimary,
    this.errorText,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primaryColor;
  final Color textPrimary;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Row(
            children: [
              Checkbox(
                value: value,
                onChanged: (checked) => onChanged(checked ?? false),
                activeColor: primaryColor,
              ),
              Expanded(
                child: Text(
                  l10n.ageConfirmationLabel,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(color: textPrimary),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText!,
              style: AppTextStyles.captionSmall(context)
                  .copyWith(color: cs.error),
            ),
          ),
      ],
    );
  }
}
