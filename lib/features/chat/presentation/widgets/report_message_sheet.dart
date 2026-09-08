import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lueur/core/constants/app_sizes.dart';
import 'package:lueur/core/constants/app_spacing.dart';
import 'package:lueur/core/injection/injection.dart';
import 'package:lueur/core/styling/app_colors.dart';
import 'package:lueur/core/styling/theme_extensions.dart';
import 'package:lueur/core/styling/theme_text_styles.dart';
import 'package:lueur/features/report/presentation/cubit/report_cubit.dart';
import 'package:lueur/features/report/presentation/cubit/report_state.dart';
import 'package:lueur/l10n/app_localizations.dart';

const _reasonOffensive = 'offensive_harmful';
const _reasonInaccurate = 'inaccurate';
const _reasonUncomfortable = 'uncomfortable';
const _reasonOther = 'other';

/// Bottom sheet for flagging one of Luna's chat replies, satisfying Google
/// Play's requirement that AI-generated content be reportable in-app.
Future<void> showReportMessageSheet(
  BuildContext context, {
  required String reportedText,
  String? userMessage,
}) {
  final rootMessenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;

  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider(
      create: (_) => sl<ReportCubit>(),
      child: _ReportMessageSheetContent(
        reportedText: reportedText,
        userMessage: userMessage,
        rootMessenger: rootMessenger,
        successMessage: l10n.chatReportSuccessSnack,
      ),
    ),
  );
}

class _ReportMessageSheetContent extends StatefulWidget {
  const _ReportMessageSheetContent({
    required this.reportedText,
    required this.userMessage,
    required this.rootMessenger,
    required this.successMessage,
  });

  final String reportedText;
  final String? userMessage;
  final ScaffoldMessengerState rootMessenger;
  final String successMessage;

  @override
  State<_ReportMessageSheetContent> createState() =>
      _ReportMessageSheetContentState();
}

class _ReportMessageSheetContentState
    extends State<_ReportMessageSheetContent> {
  late final TextEditingController _commentController;
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final reason = _selectedReason;
    if (reason == null) return;
    context.read<ReportCubit>().submitReport(
          reportedText: widget.reportedText,
          userMessage: widget.userMessage,
          reason: reason,
          comment: _commentController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ReportCubit, ReportState>(
      listener: (context, state) {
        if (state is ReportSuccess) {
          Navigator.of(context).pop();
          widget.rootMessenger.showSnackBar(
            SnackBar(content: Text(widget.successMessage)),
          );
        } else if (state is ReportFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.chatReportErrorSnack)),
          );
        }
      },
      child: SafeArea(
        child: Material(
          color: context.extra.cardBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.borderRadiusXl),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.horizontalPaddingLg,
              AppSpacing.spaceMd,
              AppSpacing.horizontalPaddingLg,
              AppSpacing.space2Xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceLg),
                  Text(
                    l10n.chatReportTitle,
                    style: ThemeTextStyles.titleMedium(context),
                  ),
                  SizedBox(height: AppSpacing.spaceSm),
                  RadioGroup<String>(
                    groupValue: _selectedReason,
                    onChanged: (value) => setState(() => _selectedReason = value),
                    child: Column(children: _buildReasonTiles(l10n)),
                  ),
                  SizedBox(height: AppSpacing.spaceSm),
                  TextField(
                    controller: _commentController,
                    minLines: 2,
                    maxLines: 4,
                    style: ThemeTextStyles.bodyMedium(context),
                    decoration: InputDecoration(
                      hintText: l10n.chatReportCommentHint,
                    ),
                  ),
                  SizedBox(height: AppSpacing.spaceLg),
                  BlocBuilder<ReportCubit, ReportState>(
                    builder: (context, state) {
                      final submitting = state is ReportSubmitting;
                      return SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeightMd,
                        child: FilledButton(
                          onPressed: _selectedReason == null || submitting
                              ? null
                              : _submit,
                          child: submitting
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.chatReportSubmitButton),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReasonTiles(AppLocalizations l10n) {
    final options = <String, String>{
      _reasonOffensive: l10n.chatReportReasonOffensive,
      _reasonInaccurate: l10n.chatReportReasonInaccurate,
      _reasonUncomfortable: l10n.chatReportReasonUncomfortable,
      _reasonOther: l10n.chatReportReasonOther,
    };

    return options.entries
        .map(
          (entry) => RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            value: entry.key,
            title: Text(
              entry.value,
              style: ThemeTextStyles.bodyLarge(context),
            ),
          ),
        )
        .toList();
  }
}
