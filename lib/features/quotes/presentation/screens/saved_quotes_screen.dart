import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur_app/core/constants/app_spacing.dart';
import 'package:lueur_app/core/routing/app_routes.dart';
import 'package:lueur_app/core/styling/app_colors.dart';
import 'package:lueur_app/core/styling/theme_extensions.dart';
import 'package:lueur_app/core/styling/theme_text_styles.dart';
import 'package:lueur_app/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur_app/features/quotes/presentation/cubit/saved_quotes_state.dart';

class SavedQuotesScreen extends StatelessWidget {
  const SavedQuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPaddingLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSpacing.space3Xl),
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.profile),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Saved quotes',
                      style: ThemeTextStyles.headlineSmall(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              SizedBox(height: AppSpacing.sectionSpacingMd),
              Expanded(
                child: BlocBuilder<SavedQuotesCubit, SavedQuotesState>(
                  builder: (context, state) {
                    if (state is SavedQuotesLoading) {
                      return Center(
                        child: Text(
                          'Loading saved quotes...',
                          style: ThemeTextStyles.bodyMedium(context),
                        ),
                      );
                    }

                    if (state is SavedQuotesLoaded && state.quotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bookmark_rounded,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(height: AppSpacing.spaceSm),
                            Text(
                              'No saved quotes yet',
                              style: ThemeTextStyles.titleMedium(context),
                            ),
                            SizedBox(height: AppSpacing.spaceXs),
                            Text(
                              'Save Luna’s words to collect them here',
                              style: ThemeTextStyles.bodySmall(context).copyWith(
                                color: context.extra.secondaryTextColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is SavedQuotesLoaded) {
                      return ListView.builder(
                        itemCount: state.quotes.length,
                        itemBuilder: (context, index) {
                          final quote = state.quotes[index];
                          return Dismissible(
                            key: ValueKey(quote.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete quote?'),
                                      content: const Text(
                                        'This will remove the saved quote.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: AppColors.errorColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) {
                              final cubit = context.read<SavedQuotesCubit>();
                              final messenger = ScaffoldMessenger.of(context);
                              final quoteText = quote.text;
                              final quoteEmoji = quote.emoji;
                              final quoteThoughts = quote.thoughts;
                              final quoteId = quote.id;
                              cubit.deleteQuote(quoteId);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: const Text('Quote deleted'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => cubit.saveQuote(
                                      quoteText,
                                      emoji: quoteEmoji,
                                      thoughts: quoteThoughts,
                                    ),
                                  ),
                                ),
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.whiteTextColor,
                                size: 26,
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: AppSpacing.spaceMd),
                              padding: EdgeInsets.all(AppSpacing.spaceLg),
                              decoration: BoxDecoration(
                                color: context.extra.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: context.extra.borderColor ??
                                      Theme.of(context).colorScheme.outline,
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (quote.emoji != null) ...[
                                        Text(
                                          quote.emoji!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontFamilyFallback: [
                                              'Apple Color Emoji',
                                              'Noto Color Emoji',
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Expanded(
                                        child: Text(
                                          '"${quote.text}"',
                                          style:
                                              ThemeTextStyles.bodyMedium(context),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.bookmark_rounded,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.5),
                                      ),
                                    ],
                                  ),
                                  if (quote.thoughts != null &&
                                      quote.thoughts!.isNotEmpty) ...[
                                    SizedBox(height: AppSpacing.spaceXs),
                                    Text(
                                      quote.thoughts!,
                                      style: ThemeTextStyles.bodySmall(context)
                                          .copyWith(
                                        color: context.extra.secondaryTextColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
              SizedBox(height: AppSpacing.sectionSpacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
