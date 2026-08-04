import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// A single chat bubble with a light bounce-scale on tap — purely a tactile
/// touch, no navigation or side effect, so it stays a tiny self-contained
/// widget instead of triggering a rebuild of the whole message list.
class ChatBubble extends StatefulWidget {
  final String content;
  final bool isUser;

  const ChatBubble({super.key, required this.content, required this.isUser});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  static const Curve _bounceBackCurve = Cubic(0.34, 1.56, 0.64, 1.0);

  bool _pressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final extra = context.extra;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: Duration(milliseconds: _pressed ? 100 : 300),
        curve: _pressed ? Curves.easeOut : _bounceBackCurve,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingMd,
            vertical: AppSpacing.verticalPaddingSm,
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72,
          ),
          decoration: BoxDecoration(
            color: widget.isUser
                ? AppColors.primaryButtonFill
                : extra.cardBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.r),
              topRight: Radius.circular(18.r),
              bottomLeft: Radius.circular(widget.isUser ? 18.r : 4.r),
              bottomRight: Radius.circular(widget.isUser ? 4.r : 18.r),
            ),
            boxShadow: [
              BoxShadow(
                color: (extra.shadowColor ?? AppColors.overlayBlack)
                    .withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            widget.content,
            style: ThemeTextStyles.bodyMedium(context).copyWith(
              color: widget.isUser
                  ? AppColors.whiteTextColor
                  : extra.primaryTextColor,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
