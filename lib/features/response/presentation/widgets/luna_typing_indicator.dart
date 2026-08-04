import 'package:flutter/material.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/l10n/app_localizations.dart';

/// "Luna is thinking" indicator shown while waiting for the AI response.
class LunaTypingIndicator extends StatefulWidget {
  const LunaTypingIndicator({super.key});

  @override
  State<LunaTypingIndicator> createState() => _LunaTypingIndicatorState();
}

class _LunaTypingIndicatorState extends State<LunaTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = ThemeTextStyles.bodyMedium(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final dot1 = value < 0.33 ? 1.0 : 0.3;
        final dot2 = value >= 0.33 && value < 0.66 ? 1.0 : 0.3;
        final dot3 = value >= 0.66 ? 1.0 : 0.3;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.responseThinkingLabel,
              style: textStyle,
            ),
            SizedBox(height: AppSpacing.spaceSm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(opacity: dot1),
                SizedBox(width: AppSpacing.spaceSm),
                _Dot(opacity: dot2),
                SizedBox(width: AppSpacing.spaceSm),
                _Dot(opacity: dot3),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: const Text('●'),
    );
  }
}
