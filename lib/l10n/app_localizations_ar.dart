// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Lueur';

  @override
  String get themeModeLight => 'فاتح';

  @override
  String get themeModeDark => 'داكن';

  @override
  String get themeModeSystem => 'النظام';

  @override
  String get responseScreenTitle => 'رد لونا';

  @override
  String streakDaysWithLuna(int days) {
    return '$days يوم مع لونا 🌸';
  }

  @override
  String homeGreetingMessage(String name, int streak) {
    return 'مساء الخير يا $name 🌙 $streak يوم متواصل — أنا فخورة بك';
  }

  @override
  String homeGreetingNoEntries(String name) {
    return 'مرحباً $name، أنا لونا. أنا هنا كلما كنت مستعداً للحديث 🌱';
  }

  @override
  String homeGreetingMorningStreak(String name, int streak) {
    return 'صباح الخير يا $name! $streak يوم متواصل — هذا جميل 🌸';
  }

  @override
  String homeGreetingMorning(String name) {
    return 'صباح الخير يا $name ☀️ ما الذي يشغل قلبك اليوم؟';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'أهلاً $name 🌤️ كيف يمر يومك حتى الآن؟';
  }

  @override
  String homeGreetingEveningNoStreak(String name) {
    return 'مساء الخير يا $name 🌙 أنا هنا إذا أردت الحديث';
  }

  @override
  String homeGreetingLateNight(String name) {
    return 'أهلاً $name ⭐ ما زلت مستيقظاً؟ أنا أستمع';
  }

  @override
  String get appTagline => 'نور صغير من أجلك';

  @override
  String get onboardingSkip => 'تخطي المقدمة';

  @override
  String get onboardingTitle1 => 'مساحة هادئة،\nخاصة بك فقط';

  @override
  String get onboardingSubtitle1 => 'تحدث عن شعورك —\nمن غير ضغط، فقط حضور';

  @override
  String get onboardingTitle2 => 'تعرّف على لونا،\nرفيقتك';

  @override
  String get onboardingSubtitle2 =>
      'رفيقة ودودة للكتابة والتأمل،\nوليست بديلاً عن الإرشاد المتخصص';

  @override
  String get onboardingTitle3 => 'خطوات صغيرة،\nنمو حقيقي';

  @override
  String get onboardingSubtitle3 =>
      'كن حاضراً لنفسك كل يوم\nوشاهد شيئاً جميلاً ينمو';

  @override
  String get loginWelcomeBack => 'أهلاً بعودتك';

  @override
  String get loginSubtitle => 'لونا اشتاقت لك';

  @override
  String get loginCta => 'تحدث مع لونا';

  @override
  String get loginSignUpPrompt => 'ليس لديك حساب؟ ';

  @override
  String get loginSignUpAction => 'ابدأ النمو';

  @override
  String get registerTitle => 'ابدأ رحلتك';

  @override
  String get registerSubtitle => 'لونا جاهزة للاستماع إليك';

  @override
  String get registerCta => 'ابدأ النمو';

  @override
  String get registerSignInPrompt => 'لديك حساب بالفعل؟ ';

  @override
  String get registerSignInAction => 'تسجيل الدخول';

  @override
  String get authContinueAsGuest => 'المتابعة كضيف';

  @override
  String get guestWarningTitle => 'تنبيه بسيط';

  @override
  String get guestWarningMessage =>
      'عند المتابعة كضيف، لن تتذكر لونا مدخلاتك بعد إغلاق التطبيق. هل تريد الحفاظ على أيامك المتتالية؟ يمكنك التسجيل في أي وقت.';

  @override
  String get guestWarningRegisterInstead => 'التسجيل بدلاً من ذلك';

  @override
  String get authLogOut => 'تسجيل الخروج';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'your@email.com';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authFullNameLabel => 'الاسم الكامل';

  @override
  String get authFullNameHint => 'اسمك';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authOrDivider => 'أو';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وستُرسل لك لونا رابطاً للعودة';

  @override
  String get forgotPasswordCta => 'إرسال رابط إعادة التعيين';

  @override
  String get forgotPasswordSuccessTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get forgotPasswordSuccessSubtitle =>
      'أرسلنا رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. اتبعه لتعيين كلمة مرور جديدة';

  @override
  String get forgotPasswordBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get authContinueWithGoogle => 'المتابعة عبر جوجل';

  @override
  String get authSignUpWithGoogle => 'التسجيل عبر جوجل';

  @override
  String get passwordStrengthTooShort => 'قصيرة جداً';

  @override
  String get passwordStrengthGettingThere => 'على الطريق الصحيح';

  @override
  String get passwordStrengthStrong => 'قوية';

  @override
  String get authEmailInvalid => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get authPasswordTooShort => 'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authConfirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get authConfirmPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authFieldRequired => 'هذا الحقل مطلوب';

  @override
  String get authErrorUserNotFound =>
      'لم نجد حسابًا مرتبطًا بهذا البريد الإلكتروني.';

  @override
  String get authErrorWrongPassword =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrorEmailInUse => 'يوجد حساب بالفعل بهذا البريد الإلكتروني.';

  @override
  String get authErrorInvalidEmail => 'من فضلك أدخل بريدًا إلكترونيًا صحيحًا.';

  @override
  String get authErrorWeakPassword =>
      'كلمة المرور ضعيفة قليلًا — استخدم 6 أحرف على الأقل.';

  @override
  String get authErrorUserDisabled => 'هذا الحساب موقوف حاليًا.';

  @override
  String get authErrorTooManyRequests =>
      'محاولات كثيرة في وقت قصير — جرّب مرة أخرى بعد قليل.';

  @override
  String get authErrorNetworkFailed =>
      'لا يوجد اتصال بالإنترنت. تحقق من شبكتك وحاول مرة أخرى.';

  @override
  String get authErrorGeneric => 'لم تنجح المحاولة هذه المرة، جرّب مرة أخرى.';

  @override
  String get authErrorLoginFailed => 'لم يتم تسجيل الدخول، جرّب مرة أخرى.';

  @override
  String get authErrorRegisterFailed => 'لم يتم إنشاء الحساب، جرّب مرة أخرى.';

  @override
  String get authErrorLogoutFailed => 'لم يتم تسجيل الخروج، جرّب مرة أخرى.';

  @override
  String get authErrorGoogleSyncFailed =>
      'تم تسجيل الدخول بجوجل، لكن مزامنة حسابك لم تنجح. جرّب مرة أخرى.';

  @override
  String get authErrorGoogleSignInFailed =>
      'لم ينجح تسجيل الدخول بجوجل، جرّب مرة أخرى.';

  @override
  String get authErrorResetEmailFailed =>
      'لم نتمكن من إرسال رابط إعادة التعيين، جرّب مرة أخرى.';

  @override
  String get authErrorSyncLanguageFailed => 'لم تتم مزامنة اللغة المفضلة.';

  @override
  String get moodLabelHappy => 'سعيد';

  @override
  String get moodLabelSad => 'حزين';

  @override
  String get moodLabelAngry => 'غاضب';

  @override
  String get moodLabelAnxious => 'غير مرتاح';

  @override
  String get moodLabelCalm => 'هادئ';

  @override
  String get moodLabelExcited => 'متحمس';

  @override
  String get moodLabelGrateful => 'ممتن';

  @override
  String get moodLabelHopeful => 'متفائل';

  @override
  String get moodLabelLonely => 'وحيد';

  @override
  String get moodLabelNeutral => 'عادي';

  @override
  String get moodLabelScared => 'خائف';

  @override
  String get moodLabelBurnout => 'مستنزف';

  @override
  String get moodLabelContentPeaceful => 'مرتاح وهادئ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonTalkToLuna => 'تحدث مع لونا';

  @override
  String get commonSavedToQuotesSnack => 'تم الحفظ في الاقتباسات 🌿';

  @override
  String get chatOfflineSnack =>
      'يبدو أنك غير متصل بالإنترنت — حاول مرة أخرى لاحقًا 🌙';

  @override
  String get commonDismissBarrierLabel => 'إغلاق';

  @override
  String get lunaName => 'لونا';

  @override
  String get navHomeLabel => 'الرئيسية';

  @override
  String get navJournalLabel => 'يومياتي';

  @override
  String get navProfileLabel => 'حسابي';

  @override
  String get moodEntryDeleteAllTitle => 'حذف جميع المدخلات؟';

  @override
  String get moodEntryDeleteAllMessage =>
      'سيتم حذف جميع مدخلات اليوميات من جهازك نهائياً';

  @override
  String get moodEntryDeleteAllConfirm => 'حذف الكل';

  @override
  String get moodEntryDeleteAllFailedSnack =>
      'تعذّر حذف مدخلاتك — حاول مرة أخرى.';

  @override
  String get homeMoodPromptLabel => 'كيف تشعر اليوم؟';

  @override
  String get homeThoughtsLabelSad => 'ما الذي يثقل عليك؟';

  @override
  String get homeThoughtsLabelLonely => 'ما الذي يشغل بالك؟';

  @override
  String get homeThoughtsLabelAngry => 'ما الذي أثار هذا الشعور؟';

  @override
  String get homeThoughtsLabelWorried => 'ما الذي يقلقك؟';

  @override
  String get homeThoughtsLabelBurnout => 'ما الذي يستنزفك؟';

  @override
  String get homeThoughtsLabelNeutralGood => 'ما الذي يحدث معك اليوم؟';

  @override
  String get homeThoughtsLabelFeelGood => 'ما الذي يجعلك تشعر بالرضا؟';

  @override
  String get homeThoughtsLabelGrateful => 'علام أنت ممتن؟';

  @override
  String get homeThoughtsLabelHopeful => 'ما الذي تتطلع إليه؟';

  @override
  String get homeThoughtsLabelDefault => 'أخبرني بما يجول في خاطرك...';

  @override
  String get homeMoodRequiredSnack => 'الرجاء اختيار شعورك أولاً';

  @override
  String get homeThoughtsRequiredSnack => 'الرجاء مشاركة أفكارك';

  @override
  String get homeThoughtsHint => 'ما الذي يشغل بالك اليوم...';

  @override
  String get homeThoughtsEncouragementStart => 'ما الذي يشغل بالك... 🌱';

  @override
  String get homeThoughtsEncouragementContinue => 'أكمل...';

  @override
  String get homeThoughtsEncouragementOpeningUp => 'أنت تفتح قلبك 🌿';

  @override
  String get homeThoughtsEncouragementBeautiful => 'تأمل جميل 🌸';

  @override
  String get homeThoughtsEncouragementListening => 'لونا تستمع إليك 💜';

  @override
  String get homeRecentEntriesLabel => 'ذكريات حديثة';

  @override
  String get homeSeeAllLabel => 'عرض السجل الكامل';

  @override
  String get homeStreakMotivationStart =>
      'اللحظات الصغيرة تصنع عادات ذات معنى 🌱';

  @override
  String get homeStreakMotivationActive => 'أنت تحضر لنفسك كل يوم — استمر 💜';

  @override
  String get homeStreakMotivationMilestone => 'يوم واحد فقط ونباتك سينمو 🌿';

  @override
  String homeDaysStreakChip(int streak) {
    return '$streak يوم متتالي';
  }

  @override
  String homeNextMilestoneHint(int days, int milestone) {
    return 'باقي $days يوم لـ $milestone 🌱';
  }

  @override
  String get weeklyLetterBannerTitle => 'رسالتك الأسبوعية';

  @override
  String get weeklyLetterScreenTitle => 'الرسالة الأسبوعية';

  @override
  String get weeklyLetterWaitingMessage =>
      'استمر في الكتابة — ستكون رسالتك جاهزة في نهاية الأسبوع';

  @override
  String get weeklyLetterErrorMessage =>
      'تعذر تحميل رسالتك. تحقق من الاتصال وحاول مرة أخرى';

  @override
  String get weeklyLetterRetry => 'إعادة محاولة تحميل الرسالة الأسبوعية';

  @override
  String get weeklyLetterShowLess => 'عرض أقل';

  @override
  String get weeklyLetterReadMore => 'قراءة المزيد';

  @override
  String weeklyLetterEntriesChip(int count) {
    return '$count مدخلة';
  }

  @override
  String weeklyLetterStreakChip(int count) {
    return '🔥 $count يوم متتالي';
  }

  @override
  String journalDayStreakLabel(int count) {
    return '$count يوم متتالي';
  }

  @override
  String get journalSearchHint => 'ابحث في المدخلات...';

  @override
  String get journalCardOptionsColorLabel => 'لون البطاقة';

  @override
  String get journalCardOptionsPinLabel => 'تثبيت هذا المدخل';

  @override
  String get journalCardOptionsDeleteLabel => 'حذف المدخل';

  @override
  String get journalCardOptionsDeleteTitle => 'حذف هذا المدخل؟';

  @override
  String get journalCardOptionsDeleteMessage =>
      'سيتم إزالته من يومياتك نهائياً';

  @override
  String get journalGridTitle => 'يومياتك';

  @override
  String get journalGridSubtitle => 'مجموعة صغيرة من أيامك';

  @override
  String get journalEmptyStateTitle => 'لا توجد يوميات بعد';

  @override
  String get journalGridEmptyMessage => 'كل قصة تبدأ بصفحة واحدة.';

  @override
  String get journalActionFailedSnack =>
      'تعذّر حفظ هذا التغيير — حاول مرة أخرى.';

  @override
  String get timelineTitle => 'الخط الزمني';

  @override
  String get timelineFilterAllMoods => 'كل المشاعر';

  @override
  String get timelineFilterAllMonths => 'كل الأشهر';

  @override
  String get timelineNoResultsTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get timelineNoResultsMessage =>
      'جرّب مشاعر أو شهرًا أو كلمة بحث مختلفة.';

  @override
  String get timelineReflection1 => '🌸 حمل الربيع الكثير من لحظات الأمل.';

  @override
  String get timelineReflection2 => '🌙 لقد قطعت شوطًا طويلًا منذ هذه الأيام.';

  @override
  String get timelineReflection3 => '🍂 أصبحت أيامك الهادئة أكثر تكرارًا.';

  @override
  String get timelineReflection4 => '☀️ كل مدخلة هنا هي خطوة صغيرة نحو نفسك.';

  @override
  String get journalActivityBreathing => 'أخذت لحظة تنفّس';

  @override
  String get journalActivityPuzzle => 'حلّيت لغزًا صغيرًا';

  @override
  String get journalActivityDrawing => 'رسمت رسمة صغيرة';

  @override
  String get quotesScreenTitle => 'الاقتباسات المحفوظة';

  @override
  String get quotesLoadingMessage => 'جارٍ تحميل الاقتباسات المحفوظة...';

  @override
  String get quotesEmptyTitle => 'لا توجد اقتباسات محفوظة بعد';

  @override
  String get quotesEmptySubtitle => 'ستتذكر لونا كلماتك المفضلة.';

  @override
  String get quotesDeleteTitle => 'حذف الاقتباس؟';

  @override
  String get quotesDeleteMessage => 'سيتم حذف الاقتباس المحفوظ';

  @override
  String get quotesDeletedSnack => 'تم حذف الاقتباس';

  @override
  String get quotesUndoAction => 'تراجع';

  @override
  String get quotesLoadErrorMessage =>
      'لم تستطع لونا تحميل اقتباساتك المحفوظة الآن.';

  @override
  String get responseTryAgainButton => 'حاول مرة أخرى';

  @override
  String get responseGenericErrorMessage =>
      'حدث خطأ من جانبنا — لنحاول مرة أخرى.';

  @override
  String get responseShareButton => 'مشاركة';

  @override
  String get responseDoneLabel => 'تم';

  @override
  String get responseKeepChattingLabel => 'أكمل الحديث';

  @override
  String get responseMoodTagExpressing => 'تعبير';

  @override
  String get responseMoodTagReflecting => 'تأمل';

  @override
  String get responseMoodTagGrowing => 'نمو';

  @override
  String get responseThinkingLabel => 'لونا تفكر';

  @override
  String get responseShareCardHeading => 'تقول لونا';

  @override
  String get responseYourMoodLabel => 'شعورك';

  @override
  String get responseLunaSaysLabel => 'تقول لونا';

  @override
  String get responseSaveQuoteTooltip => 'حفظ الاقتباس';

  @override
  String get responseCopiedToClipboardSnack => 'تم النسخ 🌿';

  @override
  String get lunaSubtitle => 'رفيقتك في الكتابة والتأمل';

  @override
  String get afterFeelingPromptLabel => 'كيف تشعر بعد ذلك؟';

  @override
  String get afterFeelingCalmLabel => 'هادئ';

  @override
  String get afterFeelingCalmMessage => 'شكراً لأنك منحت نفسك لحظة للتأمل';

  @override
  String get afterFeelingLovedLabel => 'محبوب';

  @override
  String get afterFeelingLovedMessage => 'تستحق كل هذا الحب. تمسّك به';

  @override
  String get afterFeelingBetterLabel => 'أفضل';

  @override
  String get afterFeelingBetterMessage => 'شكراً لأنك أخذت لحظة للتأمل';

  @override
  String get afterFeelingStillSadLabel => 'لا زلت حزيناً';

  @override
  String get afterFeelingStillSadMessage =>
      'لا بأس أن يبقى هذا الشعور. خذ وقتك وتحدث مع شخص تثق به إذا رغبت في المساندة';

  @override
  String afterFeelingYouAreFeeling(String label) {
    return 'أنت تشعر بـ $label';
  }

  @override
  String get afterFeelingTakeYourTime => 'خذ وقتك';

  @override
  String get afterFeelingTalkToLunaAgain => 'تحدث مع لونا مرة أخرى';

  @override
  String get afterFeelingThankYouLuna => 'شكراً لك يا لونا';

  @override
  String get afterFeelingImOkay => 'سأكون بخير';

  @override
  String get moodChoicePrompt => 'يوم صعب، أليس كذلك؟';

  @override
  String get moodChoiceSubPrompt => 'أياً كان ما يناسبك الآن';

  @override
  String get moodChoiceTalkSubtitle => 'شارك ما يدور في ذهنك';

  @override
  String get moodChoiceBreatheTitle => 'تنفس مع لونا';

  @override
  String get moodChoiceBreatheSubtitle => 'نفس بطيء وموجّه';

  @override
  String get moodChoiceDrawTitle => 'ارسم بحرية';

  @override
  String get moodChoiceDrawSubtitle => 'بلا ضغط، فقط ألوان';

  @override
  String get moodChoiceSudokuTitle => 'سودوكو';

  @override
  String get moodChoiceSudokuSubtitle => 'لغز صغير وهادئ';

  @override
  String get chatInputHint => 'شارك ما يدور في ذهنك...';

  @override
  String get chatEmptyStateMessage => 'مرحباً، أنا لونا 💜\nأخبرني كيف تشعر';

  @override
  String get chatTypingLabel => 'لونا تكتب';

  @override
  String get chatSessionEndGladMessage => 'يسعدني أنك تشعر بتحسن 💜';

  @override
  String get chatSessionEndSavedMessage => 'تم حفظ هذه الجلسة في يومياتك';

  @override
  String get chatBackToHomeButton => 'العودة للرئيسية';

  @override
  String get sudokuHowToPlayTitle => 'كيف تلعب';

  @override
  String get sudokuHowToPlayMessage =>
      'املأ كل صف وعمود ومربع 3×3 بالأرقام من 1 إلى 9 بدون تكرار. بدّل إلى وضع الاحتمالات لتدوين ملاحظاتك، وفعّل الوضع التلقائي لتترك للونا مسح الاحتمالات نيابة عنك تدريجياً';

  @override
  String get sudokuGotIt => 'فهمت';

  @override
  String get sudokuNewGameMenuItem => 'لعبة جديدة';

  @override
  String get sudokuDifficultyEasy => 'سهل';

  @override
  String sudokuMistakesLabel(int mistakes, int max) {
    return 'الأخطاء: $mistakes/$max';
  }

  @override
  String get sudokuPausedLabel => 'متوقف مؤقتاً';

  @override
  String get sudokuDoneButton => 'تم';

  @override
  String get sudokuOutcomeSuccessMessage => 'أحسنت! حللت اللغز 🌟';

  @override
  String get sudokuOutcomeFailMessage => 'لا بأس، بعض الألغاز تكون صعبة 🌱';

  @override
  String get sudokuResultSaveFailedNotice =>
      'تعذّر حفظ هذه الجولة في السجل — لا مشكلة، تابع اللعب!';

  @override
  String get sudokuGenerationFailedMessage =>
      'تعذّر إنشاء لغز في الوقت الحالي.';

  @override
  String get sudokuOutcomeNewGameButton => 'لعبة جديدة';

  @override
  String get sudokuOutcomeBackButton => 'رجوع';

  @override
  String get sudokuAutoCandidateModeLabel => 'الوضع التلقائي للاحتمالات';

  @override
  String get sudokuNormalModeLabel => 'عادي';

  @override
  String get sudokuCandidateModeLabel => 'احتمالات';

  @override
  String get drawTopBarTitle => 'الرسم الحر';

  @override
  String get drawUndoButton => 'تراجع';

  @override
  String get drawClearButton => 'مسح';

  @override
  String get drawSavedSnack => 'تم حفظ الرسمة في حسابك';

  @override
  String get drawSaveErrorSnack => 'تعذّر حفظ رسمتك — حاول مرة أخرى بعد قليل.';

  @override
  String get drawTalkToLunaLink => 'تشعر برغبة في التحدث مع لونا الآن؟';

  @override
  String get drawViewerTitle => 'رسمتك';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get profileSubtitle => 'عضو في Lueur';

  @override
  String get profileFallbackName => 'صديق';

  @override
  String get profileQuotesEmptySubtitle => 'ستتذكر لونا كلماتك المفضلة.';

  @override
  String get profileSettingsSectionLabel => 'الإعدادات';

  @override
  String get profileSettingsAppearance => 'المظهر';

  @override
  String get profileSettingsLanguage => 'اللغة';

  @override
  String get languageChangeFailedSnack => 'تعذّر تغيير اللغة — حاول مرة أخرى.';

  @override
  String get profileJournalDataSectionLabel => 'بيانات اليوميات';

  @override
  String get profileDeleteAllEntriesLabel => 'حذف كل مدخلات اليوميات';

  @override
  String get profileAccountSectionLabel => 'الحساب';

  @override
  String get profileDeleteAccountLabel => 'حذف الحساب';

  @override
  String get accountDeleteTitle => 'هل تريد حذف حسابك نهائياً؟';

  @override
  String get accountDeleteMessage =>
      'سيؤدي هذا إلى حذف حسابك وكل ما يرتبط به نهائياً — مدخلات اليوميات، والاقتباسات المحفوظة، والرسومات، وسجل السودوكو — من خوادمنا ومن هذا الجهاز. لا يمكن التراجع عن هذا الإجراء، وهو يختلف عن حذف مدخلات اليوميات فقط.';

  @override
  String get accountDeleteConfirm => 'حذف الحساب';

  @override
  String get accountDeleteFailedSnack => 'تعذّر حذف حسابك — حاول مرة أخرى.';

  @override
  String get profileDrawingsTitle => 'رسوماتي';

  @override
  String get profileDrawingsErrorSubtitle =>
      'تعذر تحميل رسوماتك — اسحب للتحديث وحاول مرة أخرى';

  @override
  String get profileDrawingsEmptySubtitle => 'إبداعك له بيت هنا.';

  @override
  String get profileSudokuHistoryTitle => 'سجل السودوكو';

  @override
  String get profileSudokuHistoryErrorSubtitle =>
      'تعذر تحميل سجل السودوكو — اسحب للتحديث وحاول مرة أخرى';

  @override
  String get profileSudokuHistoryEmptySubtitle =>
      'العب جولة سودوكو لترى نتائجك هنا';

  @override
  String get profileSudokuRelativeToday => 'اليوم';

  @override
  String get profileSudokuRelativeYesterday => 'أمس';

  @override
  String get profileSudokuSolvedIt => 'حلّها';

  @override
  String get profileSudokuGaveItAGo => 'حاول حلّها';

  @override
  String profileSudokuRelativeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'قبل $days أيام',
      one: 'قبل يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String profileSudokuMistakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أخطاء',
      one: 'خطأ واحد',
    );
    return '$_temp0';
  }

  @override
  String get breathingHeaderLabel => 'تمرين التنفس الموجه';

  @override
  String get breathingPhaseIn => 'شهيق';

  @override
  String get breathingPhaseOut => 'زفير';

  @override
  String get breathingConfigErrorMessage =>
      'تعذّر تحميل تمرين التنفس — لنحاول مرة أخرى.';

  @override
  String get affirmationHeader => 'كلمة من لونا 💙';

  @override
  String get affirmationSubheader => 'بطاقة خاصة بك أنت';

  @override
  String get affirmationSignature => '— لونا 🌿';

  @override
  String get affirmationNextCardButton => 'البطاقة التالية ↻';

  @override
  String get affirmationPrimaryStartBreathing => 'ابدأ التنفس';

  @override
  String get affirmationPrimaryStartDrawing => 'ابدأ الرسم';

  @override
  String get affirmationPrimaryPlaySudoku => 'العب سودوكو';

  @override
  String get lunaCheckInTitle => 'تشعر بتحسن الآن؟';

  @override
  String get lunaCheckInSubtitle => 'أنا هنا إذا أردت التحدث أكثر';

  @override
  String get lunaCheckInDismiss => 'أنا بخير الآن';

  @override
  String get streakCelebrationKeepGoingButton => 'استمر';

  @override
  String get chatSendFailedMessages0 => 'حممم لم تُرسل، حاول مرة أخرى؟';

  @override
  String get chatSendFailedMessages1 =>
      'أوه إشارتي غريبة قليلاً، أعد المحاولة؟';

  @override
  String get chatSendFailedMessages2 => 'انتظر، انقطعت الرسالة، مرة أخرى؟';

  @override
  String get chatSendFailedMessages3 =>
      'لحظة، لم أستقبلها — حاول الإرسال مرة أخرى';

  @override
  String get chatSendFailedMessages4 =>
      'حممم حدث خلل ما، هل يمكنك إعادة إرسالها؟';

  @override
  String get streakCelebrationAffirmations0 =>
      'أسبوع كامل من الحضور لنفسك. لونا لاحظت ذلك 🌸';

  @override
  String get streakCelebrationAffirmations1 =>
      'سبعة أيام من اختيار نفسك، فكرة تلو الأخرى';

  @override
  String get streakCelebrationAffirmations2 =>
      'استمررت في العودة — هذا هو السر كله في الحقيقة';

  @override
  String get streakCelebrationAffirmations3 =>
      'لونا سعيدة جداً أنك لا تزال هنا، يوماً بعد يوم';

  @override
  String get streakCelebrationAffirmations4 =>
      'هذا ما تبدو عليه العناية بنفسك. استمر';

  @override
  String get streakCelebrationAffirmations5 =>
      'أسبوع كامل، برفق وصدق. يستحق الاحتفال';

  @override
  String streakCelebrationNextMilestone(int days) {
    return '$days يوم حتى معلمك التالي';
  }

  @override
  String get streakCelebrationAllMilestonesReached =>
      'لقد وصلت إلى كل معلم — لونا مندهشة بك';

  @override
  String get streakCelebrationEyebrowLabel => 'أيام التتابع';

  @override
  String get streakCelebrationProgressSemanticLabel =>
      'التقدم نحو معلمك التالي';

  @override
  String get streakGrowthStageSeedLabel => 'بذرة 🌱';

  @override
  String get streakGrowthStageSproutLabel => 'براعم 🌿';

  @override
  String get streakGrowthStagePlantLabel => 'تنمو 🪴';

  @override
  String get streakGrowthStageBlossomLabel => 'تزهر 🌺';

  @override
  String get streakGrowthStageBloomingLabel => 'تتفتح 🌸';

  @override
  String get authSuccessTitle => 'أهلاً بك!';

  @override
  String get authSuccessMessage => 'لونا سعيدة بوجودك هنا';

  @override
  String get startupErrorMessage => 'حدث خلل بسيط ونحن نجهز الأمور';

  @override
  String get startupErrorSubtext => 'حاول مرة أخرى بعد قليل';

  @override
  String get startupErrorRetry => 'حاول مرة أخرى';
}
