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
    return 'مساء الخير يا $name 🌙 $streak يوم متواصل — إنجاز يستحق التقدير';
  }

  @override
  String homeGreetingNoEntries(String name) {
    return 'مرحباً $name، أنا لونا. أنا هنا عندما يحين وقت الحديث 🌱';
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
    return 'أهلاً $name ⭐ الوقت متأخر. أنا هنا للاستماع';
  }

  @override
  String get appTagline => 'نور صغير من أجلك';

  @override
  String get onboardingSkip => 'تخطي المقدمة';

  @override
  String get onboardingTitle1 => 'مساحة هادئة،\nخاصة بك فقط';

  @override
  String get onboardingSubtitle1 =>
      'مساحة للحديث عن شعورك —\nبلا ضغط، فقط لحظة هادئة';

  @override
  String get onboardingTitle2 => 'تعرّف على لونا،\nرفيقتك';

  @override
  String get onboardingSubtitle2 =>
      'رفيقة ودودة تعمل بالذكاء الاصطناعي للكتابة والتأمل،\nوليست بديلاً عن الإرشاد المتخصص';

  @override
  String get onboardingTitle3 => 'خطوات صغيرة،\nنمو حقيقي';

  @override
  String get onboardingSubtitle3 =>
      'حضور يومي لنفسك\nوشيء جميل ينمو أمام العين';

  @override
  String get loginWelcomeBack => 'أهلاً بعودتك';

  @override
  String get loginSubtitle => 'لونا بانتظارك';

  @override
  String get loginCta => 'الحديث مع لونا';

  @override
  String get loginSignUpPrompt => 'ليس لديك حساب؟ ';

  @override
  String get loginSignUpAction => 'لنبدأ النمو';

  @override
  String get registerTitle => 'رحلتك تبدأ هنا';

  @override
  String get registerSubtitle => 'لونا جاهزة للاستماع إليك';

  @override
  String get registerCta => 'لنبدأ النمو';

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
      'بالمتابعة كضيف لن تُحفظ مدخلاتك بعد إغلاق التطبيق. التسجيل متاح في أي وقت للحفاظ عليها وعلى أيامك المتتالية.';

  @override
  String get guestWarningRegisterInstead => 'التسجيل بدلاً من ذلك';

  @override
  String get authLogOut => 'تسجيل الخروج';

  @override
  String get profileGuestLogInLabel => 'تسجيل الدخول';

  @override
  String get profileGuestRegisterLabel => 'التسجيل';

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
      'بإدخال بريدك الإلكتروني سترسل لونا رابطاً للعودة';

  @override
  String get forgotPasswordCta => 'إرسال رابط إعادة التعيين';

  @override
  String get forgotPasswordSuccessTitle => 'رسالة بانتظارك في بريدك الإلكتروني';

  @override
  String get forgotPasswordSuccessSubtitle =>
      'أرسلنا رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني. يمكن اتباعه لتعيين كلمة مرور جديدة';

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
  String get authEmailInvalid => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get authPasswordTooShort => 'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authConfirmPasswordHint => 'إعادة إدخال كلمة المرور';

  @override
  String get authConfirmPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authFieldRequired => 'هذا الحقل مطلوب';

  @override
  String get ageConfirmationLabel => 'أنا فوق 18 سنة';

  @override
  String get ageConfirmationError => 'يرجى تأكيد أنك فوق 18 سنة للمتابعة';

  @override
  String get ageConfirmationDialogTitle => 'أمر أخير';

  @override
  String get ageConfirmationDialogMessage =>
      'يرجى تأكيد أنك فوق 18 سنة لاستخدام لونا.';

  @override
  String get ageConfirmationDialogConfirm => 'أنا فوق 18 سنة';

  @override
  String get ageConfirmationDialogDecline => 'لست فوق 18 سنة';

  @override
  String get ageConfirmationDeclinedMessage =>
      'تم حذف حسابك لأنه تعذّر تأكيد أنك فوق 18 سنة.';

  @override
  String get authErrorUserNotFound =>
      'لم نجد حسابًا مرتبطًا بهذا البريد الإلكتروني.';

  @override
  String get authErrorWrongPassword =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get authErrorEmailInUse => 'يوجد حساب بالفعل بهذا البريد الإلكتروني.';

  @override
  String get authErrorInvalidEmail => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get authErrorWeakPassword =>
      'كلمة المرور ضعيفة قليلًا — يلزم 6 أحرف على الأقل.';

  @override
  String get authErrorUserDisabled => 'هذا الحساب موقوف حاليًا.';

  @override
  String get authErrorTooManyRequests =>
      'محاولات كثيرة في وقت قصير — يمكن المحاولة مرة أخرى بعد قليل.';

  @override
  String get authErrorNetworkFailed =>
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مرة أخرى.';

  @override
  String get authErrorGeneric =>
      'لم تنجح المحاولة هذه المرة، يمكن المحاولة مرة أخرى.';

  @override
  String get authErrorLoginFailed =>
      'لم يتم تسجيل الدخول، يمكن المحاولة مرة أخرى.';

  @override
  String get authErrorRegisterFailed =>
      'لم يتم إنشاء الحساب، يمكن المحاولة مرة أخرى.';

  @override
  String get authErrorLogoutFailed =>
      'لم يتم تسجيل الخروج، يمكن المحاولة مرة أخرى.';

  @override
  String get authErrorGoogleSyncFailed =>
      'تم تسجيل الدخول بجوجل، لكن مزامنة الحساب لم تنجح. يمكن المحاولة مرة أخرى.';

  @override
  String get authErrorGoogleSignInFailed =>
      'لم ينجح تسجيل الدخول بجوجل، يمكن المحاولة مرة أخرى.';

  @override
  String get authErrorResetEmailFailed =>
      'لم نتمكن من إرسال رابط إعادة التعيين، يمكن المحاولة مرة أخرى.';

  @override
  String get authErrorSyncLanguageFailed => 'لم تتم مزامنة اللغة المفضلة.';

  @override
  String get moodLabelHappy => 'سعادة';

  @override
  String get moodLabelSad => 'حزن';

  @override
  String get moodLabelAngry => 'غضب';

  @override
  String get moodLabelAnxious => 'عدم ارتياح';

  @override
  String get moodLabelCalm => 'هدوء';

  @override
  String get moodLabelExcited => 'حماس';

  @override
  String get moodLabelGrateful => 'امتنان';

  @override
  String get moodLabelHopeful => 'أمل';

  @override
  String get moodLabelLonely => 'وحدة';

  @override
  String get moodLabelNeutral => 'عادي';

  @override
  String get moodLabelScared => 'خوف';

  @override
  String get moodLabelBurnout => 'إرهاق';

  @override
  String get moodLabelContentPeaceful => 'راحة وهدوء';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonTalkToLuna => 'الحديث مع لونا';

  @override
  String get commonSavedToQuotesSnack => 'تم الحفظ في الاقتباسات 🌿';

  @override
  String get chatOfflineSnack =>
      'يبدو أن الاتصال بالإنترنت مقطوع — يمكن المحاولة عند عودته 🌙';

  @override
  String get commonDismissBarrierLabel => 'إغلاق';

  @override
  String get lunaName => 'لونا';

  @override
  String get lunaAiSubtitle => 'رفيقة بالذكاء الاصطناعي';

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
      'سيتم حذف مدخلات اليوميات وكل ما تتذكره لونا من محادثاتكما. الرسومات والاقتباسات وسجل السودوكو تبقى على هذا الجهاز.';

  @override
  String get moodEntryDeleteAllConfirm => 'حذف الكل';

  @override
  String get moodEntryDeleteAllFailedSnack =>
      'تعذّر حذف المدخلات — ممكن نجرّب مرة ثانية بعد شوي.';

  @override
  String get homeMoodPromptLabel => 'كيف حالك اليوم؟';

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
  String get homeThoughtsLabelFeelGood => 'ما الذي يمنحك الرضا؟';

  @override
  String get homeThoughtsLabelGrateful => 'ما الذي يستحق الامتنان اليوم؟';

  @override
  String get homeThoughtsLabelHopeful => 'ما الذي يبعث فيك الأمل؟';

  @override
  String get homeThoughtsLabelDefault => 'ما الذي يجول في خاطرك؟';

  @override
  String get homeMoodRequiredSnack => 'الرجاء اختيار شعورك أولاً';

  @override
  String get homeThoughtsRequiredSnack => 'الرجاء مشاركة أفكارك';

  @override
  String get homeThoughtsHint => 'ما الذي يشغل بالك اليوم...';

  @override
  String get homeThoughtsEncouragementStart => 'ما الذي يشغل بالك... 🌱';

  @override
  String get homeThoughtsEncouragementContinue => 'هناك متسع للمزيد...';

  @override
  String get homeThoughtsEncouragementOpeningUp => 'فتح القلب خطوة جميلة 🌿';

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
  String get homeStreakMotivationActive => 'حضورك لنفسك كل يوم يصنع فرقاً 💜';

  @override
  String get homeStreakMotivationMilestone => 'باقي القليل ويكبر نباتك 🌿';

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
      'مع كل مدخلة جديدة تقترب رسالتك — ستكون جاهزة في نهاية الأسبوع';

  @override
  String get weeklyLetterErrorMessage =>
      'تعذر تحميل رسالتك. يمكن التحقق من الاتصال ثم إعادة المحاولة';

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
    return '🌿 $count يوم متتالي';
  }

  @override
  String journalDayStreakLabel(int count) {
    return '$count يوم متتالي';
  }

  @override
  String get journalSearchHint => 'البحث في المدخلات...';

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
      'تعذّر حفظ هذا التغيير — يمكن المحاولة مرة أخرى.';

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
      'يمكن تجربة مشاعر أو شهر أو كلمة بحث مختلفة.';

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
  String get journalActivityPuzzle => 'حلّ لغزاً صغيراً';

  @override
  String get journalActivityDrawing => 'رسمت رسمة صغيرة';

  @override
  String get quotesScreenTitle => 'الاقتباسات المحفوظة';

  @override
  String get quotesLoadingMessage => 'جارٍ تحميل الاقتباسات المحفوظة...';

  @override
  String get quotesEmptyTitle => 'لا توجد اقتباسات محفوظة بعد';

  @override
  String get quotesEmptySubtitle => 'الاقتباسات المحفوظة تبقى هنا على جهازك.';

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
  String get responseTryAgainButton => 'إعادة المحاولة';

  @override
  String get responseGenericErrorMessage =>
      'حدث خطأ من جانبنا — لنحاول مرة أخرى.';

  @override
  String get responseGuestBlockedTitle => 'لنجعل الأمر رسميًا';

  @override
  String get responseGuestBlockedMessage =>
      'أودّ التحدث معك في هذا، لكن ذلك يتطلب إنشاء حساب أولًا — الأمر لا يستغرق سوى لحظة، وسأكون هنا بانتظارك.';

  @override
  String get responseGuestBlockedButton => 'تسجيل الدخول للحديث مع لونا';

  @override
  String get responseShareButton => 'مشاركة';

  @override
  String get responseDoneLabel => 'تم';

  @override
  String get responseKeepChattingLabel => 'متابعة الحديث';

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
  String get afterFeelingPromptLabel => 'كيف يبدو شعورك بعد ذلك؟';

  @override
  String get afterFeelingCalmLabel => 'هدوء';

  @override
  String get afterFeelingCalmMessage => 'شكراً لأنك منحت نفسك لحظة للتأمل';

  @override
  String get afterFeelingLovedLabel => 'حب';

  @override
  String get afterFeelingLovedMessage =>
      'كل هذا الحب في محله — والتمسك به أمر جميل';

  @override
  String get afterFeelingBetterLabel => 'أفضل';

  @override
  String get afterFeelingBetterMessage => 'شكراً لأنك أخذت لحظة للتأمل';

  @override
  String get afterFeelingStillSadLabel => 'ما زال الحزن';

  @override
  String get afterFeelingStillSadMessage =>
      'لا بأس أن يبقى هذا الشعور. على مهلك، وربما يفيد التحدث مع شخص موثوق إن رغبت في المساندة';

  @override
  String afterFeelingYouAreFeeling(String label) {
    return 'الشعور الآن: $label';
  }

  @override
  String get afterFeelingTakeYourTime => 'على مهلك';

  @override
  String get afterFeelingTalkToLunaAgain => 'الحديث مع لونا مرة أخرى';

  @override
  String get afterFeelingThankYouLuna => 'شكراً لك يا لونا';

  @override
  String get afterFeelingImOkay => 'سأكون بخير';

  @override
  String get moodChoicePrompt => 'ماذا قد يناسبك الآن؟';

  @override
  String get moodChoiceSubPrompt => 'أياً كان ما يناسبك الآن';

  @override
  String get moodChoiceTalkSubtitle => 'مساحة لما يدور في ذهنك';

  @override
  String get moodChoiceBreatheTitle => 'التنفس مع لونا';

  @override
  String get moodChoiceBreatheSubtitle => 'نفس بطيء وموجّه';

  @override
  String get moodChoiceDrawTitle => 'الرسم الحر';

  @override
  String get moodChoiceDrawSubtitle => 'بلا ضغط، فقط ألوان';

  @override
  String get moodChoiceSudokuTitle => 'سودوكو';

  @override
  String get moodChoiceSudokuSubtitle => 'لغز صغير وهادئ';

  @override
  String get chatInputHint => 'ما الذي يدور في ذهنك؟';

  @override
  String get chatEmptyStateMessage => 'مرحباً، أنا لونا 💜\nكيف حالك اليوم؟';

  @override
  String get chatTypingLabel => 'لونا تكتب';

  @override
  String get chatSessionEndGladMessage => 'جميل أنك خصصت لحظة لنفسك 💜';

  @override
  String get chatSessionEndSavedMessage => 'تم حفظ هذه الجلسة في يومياتك';

  @override
  String get chatBackToHomeButton => 'العودة للرئيسية';

  @override
  String get chatReportTitle => 'ما الخطأ في هذا الرد؟';

  @override
  String get chatReportReasonOffensive => 'مسيء أو ضار';

  @override
  String get chatReportReasonInaccurate => 'غير دقيق أو غير مفيد';

  @override
  String get chatReportReasonUncomfortable => 'جعلني أشعر بعدم الارتياح';

  @override
  String get chatReportReasonOther => 'سبب آخر';

  @override
  String get chatReportCommentHint => 'ملاحظات إضافية؟ (اختياري)';

  @override
  String get chatReportSubmitButton => 'إرسال البلاغ';

  @override
  String get chatReportSuccessSnack => 'شكراً، تم إرسال بلاغك.';

  @override
  String get chatReportErrorSnack => 'حدث خطأ ما — يرجى المحاولة مرة أخرى.';

  @override
  String get sudokuHowToPlayTitle => 'كيف تلعب';

  @override
  String get sudokuHowToPlayMessage =>
      'يُملأ كل صف وعمود ومربع 3×3 بالأرقام من 1 إلى 9 دون تكرار. وضع الاحتمالات يتيح تدوين الملاحظات، والوضع التلقائي يمسح الاحتمالات تلقائياً أثناء اللعب';

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
      'تعذّر حفظ هذه الجولة في السجل — لا مشكلة، اللعب مستمر!';

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
  String get drawSaveErrorSnack =>
      'تعذّر حفظ الرسمة — ممكن نجرّب مرة ثانية بعد شوي.';

  @override
  String get drawTalkToLunaLink => 'ما رأيك بالحديث مع لونا الآن؟';

  @override
  String get drawViewerTitle => 'رسمتك';

  @override
  String get profileTitle => 'حسابي';

  @override
  String get profileSubtitle => 'من عائلة Lueur';

  @override
  String get profileGuestSubtitle => 'في وضع الضيف';

  @override
  String get profileFallbackName => 'أهلًا وسهلًا';

  @override
  String get profileQuotesEmptySubtitle =>
      'الاقتباسات المحفوظة تبقى هنا على جهازك.';

  @override
  String get profileSettingsSectionLabel => 'الإعدادات';

  @override
  String get profileSettingsAppearance => 'المظهر';

  @override
  String get profileSettingsLanguage => 'اللغة';

  @override
  String get languageChangeFailedSnack =>
      'تعذّر تغيير اللغة — يمكن المحاولة مرة أخرى.';

  @override
  String get profileJournalDataSectionLabel => 'بيانات اليوميات';

  @override
  String get profileDeleteAllEntriesLabel => 'حذف كل مدخلات اليوميات';

  @override
  String get profileAccountSectionLabel => 'الحساب';

  @override
  String get profileDeleteAccountLabel => 'حذف الحساب';

  @override
  String get accountDeleteTitle => 'حذف الحساب نهائيًا؟';

  @override
  String get accountDeleteMessage =>
      'سيؤدي هذا إلى حذف حسابك وكل ما يرتبط به نهائياً — مدخلات اليوميات، والاقتباسات المحفوظة، والرسومات، وسجل السودوكو — من خوادمنا ومن هذا الجهاز. لا يمكن التراجع عن هذا الإجراء، وهو يختلف عن حذف مدخلات اليوميات فقط.';

  @override
  String get accountDeleteConfirm => 'حذف الحساب';

  @override
  String get accountDeleteFailedSnack =>
      'تعذّر حذف الحساب — ممكن نجرّب مرة ثانية بعد شوي.';

  @override
  String get profileDrawingsTitle => 'رسوماتي';

  @override
  String get profileDrawingsErrorSubtitle =>
      'تعذّر تحميل الرسومات الآن — ممكن نرجع لها بعد شوي.';

  @override
  String get profileDrawingsEmptySubtitle => 'إبداعك له بيت هنا.';

  @override
  String get profileDrawingDeletedSnack => 'تم حذف الرسمة';

  @override
  String get profileSudokuHistoryTitle => 'سجل السودوكو';

  @override
  String get profileSudokuHistoryErrorSubtitle =>
      'تعذّر تحميل سجل السودوكو الآن — ممكن نرجع له بعد شوي.';

  @override
  String get profileSudokuHistoryEmptySubtitle =>
      'نتائج جولات السودوكو تظهر هنا.';

  @override
  String get profileSudokuResultDeletedSnack => 'تم حذف النتيجة';

  @override
  String get profileSudokuRelativeToday => 'اليوم';

  @override
  String get profileSudokuRelativeYesterday => 'أمس';

  @override
  String get profileSudokuSolvedIt => 'تم الحل ✓';

  @override
  String get profileSudokuGaveItAGo => 'محاولة';

  @override
  String profileSudokuRelativeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'قبل $days يوم',
      many: 'قبل $days يومًا',
      few: 'قبل $days أيام',
      two: 'قبل يومين',
      one: 'قبل يوم',
      zero: 'اليوم',
    );
    return '$_temp0';
  }

  @override
  String profileSudokuMistakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطأ',
      many: '$count خطأً',
      few: '$count أخطاء',
      two: 'خطآن',
      one: 'خطأ واحد',
      zero: 'بلا أخطاء',
    );
    return '$_temp0';
  }

  @override
  String get breathingHeaderLabel => 'لنتنفس مع لونا';

  @override
  String get breathingPhaseIn => 'شهيق';

  @override
  String get breathingPhaseOut => 'زفير';

  @override
  String breathingPhaseSecondsRemaining(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds ثوانٍ',
      one: 'ثانية واحدة',
    );
    return '$_temp0';
  }

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
  String get affirmationPrimaryStartBreathing => 'لنبدأ التنفس';

  @override
  String get affirmationPrimaryStartDrawing => 'لنبدأ الرسم';

  @override
  String get affirmationPrimaryPlaySudoku => 'لنلعب سودوكو';

  @override
  String get lunaCheckInTitle => 'هل تحسّن شعورك قليلاً؟';

  @override
  String get lunaCheckInSubtitle => 'أنا هنا إذا أردت التحدث أكثر';

  @override
  String get lunaCheckInDismiss => 'أنا بخير الآن';

  @override
  String get streakCelebrationKeepGoingButton => 'لنكمل';

  @override
  String get chatSendFailedMessages0 =>
      'لونا لا تستطيع الرد الآن. يمكن إعادة المحاولة بعد دقيقة.';

  @override
  String get chatSendFailedMessages1 =>
      'تعذّر على لونا الرد هذه المرة. لا بأس، يمكن إعادة الإرسال بعد قليل 🌙';

  @override
  String get chatSendFailedMessages2 =>
      'لم تصل الرسالة. يمكن إرسالها مرة أخرى بعد دقيقة.';

  @override
  String get chatSendFailedMessages3 =>
      'لونا تواجه صعوبة في الرد حالياً. المحاولة بعد قليل ممكنة.';

  @override
  String get chatSendFailedMessages4 =>
      'تعذّر الحصول على رد الآن. لحظات ثم إعادة المحاولة 💜';

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
      'هذا ما تبدو عليه العناية بالنفس. والاستمرار فيها يصنع فرقاً';

  @override
  String get streakCelebrationAffirmations5 =>
      'أسبوع كامل، برفق وصدق. يستحق الاحتفال';

  @override
  String streakCelebrationNextMilestone(int days) {
    return '$days يوم حتى المرحلة التالية';
  }

  @override
  String get streakCelebrationAllMilestonesReached =>
      'بلغت كل المراحل — إنجاز رائع';

  @override
  String get streakCelebrationEyebrowLabel => 'أيام متتالية';

  @override
  String get streakCelebrationProgressSemanticLabel =>
      'التقدم نحو المرحلة التالية';

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
  String get startupErrorSubtext => 'يمكن المحاولة مرة أخرى بعد قليل';

  @override
  String get startupErrorRetry => 'إعادة المحاولة';
}
