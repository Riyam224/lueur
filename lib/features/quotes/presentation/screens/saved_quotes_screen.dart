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
import 'package:lueur/core/utils/app_strings.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_cubit.dart';
import 'package:lueur/features/quotes/presentation/cubit/saved_quotes_state.dart';

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
                      AppStrings.quotesScreenTitle,
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
                          AppStrings.quotesLoadingMessage,
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
                              AppStrings.quotesEmptyTitle,
                              style: ThemeTextStyles.titleMedium(context),
                            ),
                            SizedBox(height: AppSpacing.spaceXs),
                            Text(
                              AppStrings.quotesEmptySubtitle,
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
                                      title: const Text(AppStrings.quotesDeleteTitle),
                                      content: const Text(
                                        AppStrings.quotesDeleteMessage,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(false),
                                          child: const Text(AppStrings.commonCancel),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dialogContext,
                                          ).pop(true),
                                          child: const Text(
                                            AppStrings.commonDelete,
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
                                  content: const Text(AppStrings.quotesDeletedSnack),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: AppStrings.quotesUndoAction,
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
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: AppSpacing.spaceMd),
                              padding: EdgeInsets.all(AppSpacing.spaceLg),
                              decoration: BoxDecoration(
                                color: context.extra.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
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
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontFamilyFallback: const [
                                              'Apple Color Emoji',
                                              'Noto Color Emoji',
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.spaceSm),
                                      ],
                                      Expanded(
                                        child: Text(
                                          '"${quote.text}"',
                                          style:
                                              ThemeTextStyles.bodyMedium(context),
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.spaceSm),
                                      Icon(
                                        Icons.bookmark_rounded,
                                        size: 18.sp,
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
