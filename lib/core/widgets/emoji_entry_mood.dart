import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lueur_app/core/constants/app_sizes.dart';
import 'package:lueur_app/core/models/mood_type.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';

/// A single mood illustration tile. Pops and floats its [MoodType.label]
/// above itself when selected.
class EmojiEntryMood extends StatefulWidget {
  final MoodType moodType;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? moodColor;

  const EmojiEntryMood({
    super.key,
    required this.moodType,
    this.onTap,
    this.isSelected = false,
    this.moodColor,
  });

  @override
  State<EmojiEntryMood> createState() => _EmojiEntryMoodState();
}

class _EmojiEntryMoodState extends State<EmojiEntryMood>
    with TickerProviderStateMixin {
  late final AnimationController _popController;
  late final AnimationController _rippleController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.isSelected) _popController.forward();
  }

  @override
  void didUpdateWidget(EmojiEntryMood old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _popController.forward(from: 0);
      _rippleController.forward(from: 0);
    } else if (!widget.isSelected && old.isSelected) {
      _popController.reverse();
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.moodColor ?? AppColors.primary;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnim, _rippleController]),
        builder: (context, child) {
          final labelOpacity = _popController.value.clamp(0.0, 1.0);
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                painter: _RipplePainter(
                  progress: _rippleController.value,
                  color: color,
                  size: AppSizes.emojiButtonSize,
                ),
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: child,
                ),
              ),
              Positioned(
                bottom: AppSizes.emojiButtonSize +
                    AppSizes.moodLabelPopupGap +
                    AppSizes.moodLabelPopupHeight * (1 - labelOpacity),
                child: Opacity(
                  opacity: labelOpacity,
                  child: _MoodLabelPopup(
                    label: widget.moodType.label,
                    color: color,
                  ),
                ),
              ),
            ],
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          width: AppSizes.emojiButtonSize,
          height: AppSizes.emojiButtonSize,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? color.withValues(alpha: 0.15)
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
            border: widget.isSelected
                ? Border.all(color: color, width: 2.w)
                : null,
          ),
          child: ClipOval(
            child: widget.moodType.assetPath.endsWith('.svg')
                ? SvgPicture.asset(
                    widget.moodType.assetPath,
                    width: AppSizes.emojiButtonSize,
                    height: AppSizes.emojiButtonSize,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    widget.moodType.assetPath,
                    width: AppSizes.emojiButtonSize,
                    height: AppSizes.emojiButtonSize,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }
}

class _MoodLabelPopup extends StatelessWidget {
  final String label;
  final Color color;

  const _MoodLabelPopup({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.moodLabelPopupHeight,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: context.extra.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusCircle),
        border: Border.all(color: color, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: context.extra.shadowColor ?? Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: ThemeTextStyles.labelSmall(context).copyWith(color: color),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double size;

  _RipplePainter({
    required this.progress,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (progress == 0.0) return;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final baseRadius = size / 2;
    final radius = baseRadius + baseRadius * 0.7 * progress;
    final opacity = (1.0 - progress) * 0.45;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.progress != progress;
}
