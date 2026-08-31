import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/routing/app_routes.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/core/widgets/response_error_state.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_state.dart';
import 'package:lueur/features/quotes/presentation/widgets/saved_quote_card.dart';
import 'package:lueur/l10n/app_localizations.dart';

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
                      AppLocalizations.of(context)!.quotesScreenTitle,
                      style: ThemeTextStyles.headlineSmall(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
              SizedBox(height: AppSpacing.sectionSpacingMd),
              Expanded(
                child: BlocBuilder<SavedQuotesCubit, SavedQuotesState>(
                  builder: (context, state) {
                    if (state is SavedQuotesLoading) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context)!.quotesLoadingMessage,
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
                              size: AppSizes.iconXl,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(height: AppSpacing.spaceSm),
                            Text(
                              AppLocalizations.of(context)!.quotesEmptyTitle,
                              style: ThemeTextStyles.titleMedium(context),
                            ),
                            SizedBox(height: AppSpacing.spaceXs),
                            Text(
                              AppLocalizations.of(context)!.quotesEmptySubtitle,
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
                                      title: Text(
                                        AppLocalizations.of(
                                          dialogContext,
                                        )!.quotesDeleteTitle,
                                      ),
                                      content: Text(
                                        AppLocalizations.of(
                                          dialogContext,
                                        )!.quotesDeleteMessage,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(false),
                                          child: Text(
                                            AppLocalizations.of(
                                              dialogContext,
                                            )!.commonCancel,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(true),
                                          child: Text(
                                            AppLocalizations.of(
                                              dialogContext,
                                            )!.commonDelete,
                                            style: const TextStyle(color: AppColors.errorColor),
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
                                  content: Text(
                                    AppLocalizations.of(context)!.quotesDeletedSnack,
                                  ),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: AppLocalizations.of(context)!.quotesUndoAction,
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
                              padding: EdgeInsets.only(right: AppSpacing.spaceXl),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor,
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.whiteTextColor,
                                size: 26.sp,
                              ),
                            ),
                            child: SavedQuoteCard(
                              quote: quote,
                              showBookmarkIcon: true,
                            ),
                          );
                        },
                      );
                    }

                    if (state is SavedQuotesError) {
                      return ResponseErrorState(
                        message:
                            AppLocalizations.of(context)!.quotesLoadErrorMessage,
                        retryLabel:
                            AppLocalizations.of(context)!.responseTryAgainButton,
                        onRetry: () =>
                            context.read<SavedQuotesCubit>().loadQuotes(),
                      );
                    }

                    // SavedQuotesInitial is emitted only for the instant
                    // between cubit construction and the immediate
                    // `..loadQuotes()` call that creates it — never actually
                    // reaches this build.
                    return Center(
                      child: Text(
                        AppLocalizations.of(context)!.quotesLoadingMessage,
                        style: ThemeTextStyles.bodyMedium(context),
                      ),
                    );
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
