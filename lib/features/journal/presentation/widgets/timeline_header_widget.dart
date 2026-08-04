import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';

/// Back button + title row shown at the top of the timeline screen.
class TimelineHeaderWidget extends StatelessWidget {
  const TimelineHeaderWidget({
    super.key,
    required this.title,
    required this.headingColor,
  });

  final String title;
  final Color headingColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: headingColor,
        ),
        Expanded(
          child: Text(
            title,
            style: ThemeTextStyles.headlineMedium(context)
                .copyWith(color: headingColor),
          ),
        ),
      ],
    );
  }
}
